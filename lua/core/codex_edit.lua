--- Codex range-edit integration for Neovim.
--- Builds edit prompts from buffer context, runs the Codex CLI, and applies returned replacements.
--- 2026
local M = {}

local namespace = vim.api.nvim_create_namespace("codex_edit")
local spinner_frames = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }

---Show a scheduled Neovim notification for Codex edit status.
---@param message string
---@param level? integer
local function notify(message, level)
	vim.schedule(function()
		vim.notify(message, level or vim.log.levels.INFO, { title = "Codex" })
	end)
end

---Remove one surrounding Markdown code fence from Codex output when present.
---@param text string
---@return string
local function strip_code_fence(text)
	local fenced = text:match("^```[%w_%-%.]*[ \t]*\n(.*)\n```[ \t]*\n?$")
	return fenced or text
end

---Normalize Codex replacement text into lines suitable for buffer APIs.
---@param text string
---@return string[]
local function replacement_lines(text)
	text = strip_code_fence(text:gsub("\r\n", "\n"):gsub("\r", "\n"))

	if text:sub(-1) == "\n" then
		text = text:sub(1, -2)
	end

	return vim.split(text, "\n", { plain = true })
end

---Collect lightweight buffer context that helps Codex preserve local style.
---@return { filetype: string, path: string }
local function current_context()
	local path = vim.api.nvim_buf_get_name(0)
	if path == "" then
		path = "[No Name]"
	end

	return {
		filetype = vim.bo.filetype ~= "" and vim.bo.filetype or "text",
		path = path,
	}
end

---Build the strict edit prompt sent to `codex exec`.
---@param instruction string
---@param selected_text string
---@return string
local function codex_prompt(instruction, selected_text)
	local context = current_context()

	return table.concat({
		"You are editing a Neovim buffer range.",
		"Return only the replacement text for the provided range.",
		"Do not use Markdown fences.",
		"Do not explain the change.",
		"Do not include surrounding unchanged file content unless it is part of the replacement range.",
		"Make the smallest change that satisfies the instruction.",
		"Preserve indentation, style, and line endings implied by the selected text.",
		"If the correct edit deletes the whole range, return exactly: CODEX_DELETE_RANGE",
		"",
		("File: %s"):format(context.path),
		("Filetype: %s"):format(context.filetype),
		("Instruction: %s"):format(instruction),
		"",
		"Selected text:",
		"<<<CODEX_EDIT_SELECTION",
		selected_text,
		"CODEX_EDIT_SELECTION",
	}, "\n")
end

---Read Codex's clean final response file, falling back to stdout.
---@param path string
---@param stdout? string
---@return string
local function read_output_file(path, stdout)
	local ok, lines = pcall(vim.fn.readfile, path)
	if ok and #lines > 0 then
		return table.concat(lines, "\n")
	end

	return stdout or ""
end

---Best-effort cleanup for a temporary file.
---@param path string
local function delete_file(path)
	pcall(vim.uv.fs_unlink, path)
end

---Stop the inline spinner and optionally preserve its extmark for replacement.
---@param spinner? table
---@param keep_mark? boolean
local function stop_spinner(spinner, keep_mark)
	if not spinner then
		return
	end

	if spinner.stopped then
		return
	end
	spinner.stopped = true

	if spinner.timer then
		pcall(function()
			spinner.timer:stop()
			spinner.timer:close()
		end)
	end

	if not keep_mark and vim.api.nvim_buf_is_valid(spinner.bufnr) then
		vim.api.nvim_buf_del_extmark(spinner.bufnr, namespace, spinner.mark)
	end
end

---Return whole-line text for an inclusive line range.
---@param bufnr integer
---@param line1 integer
---@param line2 integer
---@return string
local function line_text(bufnr, line1, line2)
	local lines = vim.api.nvim_buf_get_lines(bufnr, line1 - 1, line2, false)
	return table.concat(lines, "\n")
end

---Return the byte length of a buffer line.
---@param bufnr integer
---@param row integer Zero-based row.
---@return integer
local function line_length(bufnr, row)
	return #(vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1] or "")
end

---Resolve a charwise visual selection into a text-edit range when possible.
---@param bufnr integer
---@param opts table User command callback options.
---@return table? edit_range
local function visual_text_range(bufnr, opts)
	if opts.range == 0 or vim.fn.visualmode() ~= "v" then
		return nil
	end

	local start_pos = vim.fn.getpos("'<")
	local end_pos = vim.fn.getpos("'>")
	local start_row = start_pos[2] - 1
	local end_row = end_pos[2] - 1
	local start_col = start_pos[3] - 1
	local end_col = end_pos[3]

	if start_row > end_row or (start_row == end_row and start_col > end_col) then
		start_row, end_row = end_row, start_row
		start_col, end_col = end_col, start_col
	end

	if start_row ~= opts.line1 - 1 or end_row ~= opts.line2 - 1 then
		return nil
	end

	end_col = math.min(end_col, line_length(bufnr, end_row))

	return {
		kind = "text",
		start_row = start_row,
		start_col = start_col,
		end_row = end_row,
		end_col = end_col,
	}
end

---Create a whole-line edit range.
---@param line1 integer
---@param line2 integer
---@return { kind: "lines", line1: integer, line2: integer }
local function line_range(line1, line2)
	return {
		kind = "lines",
		line1 = line1,
		line2 = line2,
	}
end

---Read the current buffer text covered by an edit range.
---@param bufnr integer
---@param edit_range table
---@return string
local function selected_text(bufnr, edit_range)
	if edit_range.kind == "text" then
		local lines = vim.api.nvim_buf_get_text(
			bufnr,
			edit_range.start_row,
			edit_range.start_col,
			edit_range.end_row,
			edit_range.end_col,
			{}
		)
		return table.concat(lines, "\n")
	end

	return line_text(bufnr, edit_range.line1, edit_range.line2)
end

---Create extmarks around a whole-line range so the target survives edits.
---@param bufnr integer
---@param line1 integer
---@param line2 integer
---@return integer start_mark
---@return integer end_mark
local function mark_line_range(bufnr, line1, line2)
	local end_line = vim.api.nvim_buf_get_lines(bufnr, line2 - 1, line2, false)[1] or ""
	local start_mark = vim.api.nvim_buf_set_extmark(bufnr, namespace, line1 - 1, 0, {
		right_gravity = false,
	})
	local end_mark = vim.api.nvim_buf_set_extmark(bufnr, namespace, line2 - 1, #end_line, {
		right_gravity = true,
	})

	return start_mark, end_mark
end

---Create extmarks around a charwise text range.
---@param bufnr integer
---@param edit_range table
---@return integer start_mark
---@return integer end_mark
local function mark_text_range(bufnr, edit_range)
	local start_mark = vim.api.nvim_buf_set_extmark(bufnr, namespace, edit_range.start_row, edit_range.start_col, {
		right_gravity = false,
	})
	local end_mark = vim.api.nvim_buf_set_extmark(bufnr, namespace, edit_range.end_row, edit_range.end_col, {
		right_gravity = true,
	})

	return start_mark, end_mark
end

---Create range extmarks for either whole-line or charwise edits.
---@param bufnr integer
---@param edit_range table
---@return integer start_mark
---@return integer end_mark
local function mark_range(bufnr, edit_range)
	if edit_range.kind == "text" then
		return mark_text_range(bufnr, edit_range)
	end

	return mark_line_range(bufnr, edit_range.line1, edit_range.line2)
end

---Render an inline spinner at the range start while Codex is running.
---@param bufnr integer
---@param start_mark integer
---@return table spinner
local function start_spinner(bufnr, start_mark)
	local timer = vim.uv.new_timer()
	local spinner = {
		bufnr = bufnr,
		frame = 1,
		mark = start_mark,
		timer = timer,
	}

	if not timer then
		return spinner
	end

	timer:start(0, 120, function()
		vim.schedule(function()
			if not vim.api.nvim_buf_is_valid(bufnr) then
				stop_spinner(spinner)
				return
			end

			local pos = vim.api.nvim_buf_get_extmark_by_id(bufnr, namespace, start_mark, {})
			if #pos == 0 then
				stop_spinner(spinner)
				return
			end

			vim.api.nvim_buf_set_extmark(bufnr, namespace, pos[1], pos[2], {
				id = start_mark,
				right_gravity = false,
				virt_text = { { spinner_frames[spinner.frame] .. " Working...", "Comment" } },
				virt_text_pos = "inline",
			})

			spinner.frame = (spinner.frame % #spinner_frames) + 1
		end)
	end)

	return spinner
end

---Apply Codex's replacement to the marked range.
---@param bufnr integer
---@param edit_range table
---@param start_mark integer
---@param end_mark integer
---@param text string
local function apply_replacement(bufnr, edit_range, start_mark, end_mark, text)
	local start_pos = vim.api.nvim_buf_get_extmark_by_id(bufnr, namespace, start_mark, {})
	local end_pos = vim.api.nvim_buf_get_extmark_by_id(bufnr, namespace, end_mark, {})

	if #start_pos == 0 or #end_pos == 0 then
		notify("Could not find the original edit range.", vim.log.levels.ERROR)
		return
	end

	local lines = replacement_lines(text)
	if vim.trim(text) == "CODEX_DELETE_RANGE" then
		lines = {}
	end

	if edit_range.kind == "text" then
		vim.api.nvim_buf_set_text(bufnr, start_pos[1], start_pos[2], end_pos[1], end_pos[2], lines)
	else
		vim.api.nvim_buf_set_lines(bufnr, start_pos[1], end_pos[1] + 1, false, lines)
	end

	vim.api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)
	notify("Applied Codex edit.")
end

---Run a Codex edit for the command-provided range.
---@param opts table User command callback options.
function M.edit(opts)
	local instruction = vim.trim(opts.args or "")
	if instruction == "" then
		notify("Add an instruction after the command.", vim.log.levels.ERROR)
		return
	end

	local bufnr = vim.api.nvim_get_current_buf()
	local edit_range = visual_text_range(bufnr, opts) or line_range(opts.line1, opts.line2)
	local text = selected_text(bufnr, edit_range)

	if text == "" and edit_range.kind == "text" then
		notify("The selected range is empty.", vim.log.levels.ERROR)
		return
	end

	if vim.fn.executable("codex") ~= 1 then
		notify("The codex CLI is not available on PATH.", vim.log.levels.ERROR)
		return
	end

	local start_mark, end_mark = mark_range(bufnr, edit_range)
	local spinner = start_spinner(bufnr, start_mark)
	local output_file = vim.fn.tempname()
	local prompt = codex_prompt(instruction, text)

	notify("Asking Codex...")

	vim.system({
		"codex",
		"--ask-for-approval",
		"never",
		"exec",
		"--ephemeral",
		"--skip-git-repo-check",
		"--sandbox",
		"read-only",
		"--color",
		"never",
		"--output-last-message",
		output_file,
		"-",
	}, {
		text = true,
		stdin = prompt,
	}, function(result)
		local output = read_output_file(output_file, result.stdout)
		delete_file(output_file)

		vim.schedule(function()
			if not vim.api.nvim_buf_is_valid(bufnr) then
				stop_spinner(spinner)
				return
			end

			if result.code ~= 0 then
				stop_spinner(spinner)
				local message = vim.trim(result.stderr or result.stdout or "Codex command failed.")
				notify(message, vim.log.levels.ERROR)
				return
			end

			if vim.trim(output) == "" then
				stop_spinner(spinner)
				notify("Codex returned an empty replacement.", vim.log.levels.ERROR)
				return
			end

			stop_spinner(spinner, true)
			apply_replacement(bufnr, edit_range, start_mark, end_mark, output)
		end)
	end)
end

---Register the `:CodexLine` and `:CodexEdit` user commands.
function M.setup()
	vim.api.nvim_create_user_command("CodexLine", function(opts)
		local line = vim.api.nvim_win_get_cursor(0)[1]
		M.edit({
			args = opts.args,
			line1 = line,
			line2 = line,
			range = 0,
		})
	end, {
		nargs = "+",
		desc = "Ask Codex to replace the current line",
	})

	vim.api.nvim_create_user_command("CodexEdit", function(opts)
		M.edit(opts)
	end, {
		nargs = "+",
		range = true,
		desc = "Ask Codex to replace the selected text",
	})
end

return M
