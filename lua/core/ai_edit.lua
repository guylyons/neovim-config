--- Inline AI range-edit integration for Neovim.
--- Builds edit prompts from buffer context, runs the Claude CLI, and applies returned replacements.
--- 2026
local M = {}

local namespace = vim.api.nvim_create_namespace("ai_edit")
local spinner_frames = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }

---Show a scheduled Neovim notification for AI edit status.
---@param message string
---@param level? integer
local function notify(message, level)
	vim.schedule(function()
		vim.notify(message, level or vim.log.levels.INFO, { title = "AI Edit" })
	end)
end

---Remove one surrounding Markdown code fence from model output when present.
---@param text string
---@return string
local function strip_code_fence(text)
	local fenced = text:match("^```[%w_%-%.]*[ \t]*\n(.*)\n```[ \t]*\n?$")
	return fenced or text
end

-- The model must wrap its replacement between these marker lines. Extracting only
-- the delimited block means any stray prose the model emits is discarded instead of
-- being written into the buffer, and a reply with no block is rejected outright.
local REPLACEMENT_OPEN = "<<<AI_REPLACEMENT"
local REPLACEMENT_CLOSE = ">>>AI_REPLACEMENT"

---Extract the replacement lines from a model reply.
---@param raw string
---@return string[]? lines Replacement lines, an empty table to delete the range, or nil when no block was found.
function M.parse_response(raw)
	raw = (raw or ""):gsub("\r\n", "\n"):gsub("\r", "\n")

	local body = raw:match(REPLACEMENT_OPEN .. "[ \t]*\n(.-)" .. REPLACEMENT_CLOSE)
	if not body then
		return nil
	end

	body = body:gsub("\n$", "")
	body = strip_code_fence(body)

	if body == "" then
		return {}
	end

	return vim.split(body, "\n", { plain = true })
end

---Collect lightweight buffer context that helps the model preserve local style.
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

---Build the strict edit prompt sent to the model.
---@param instruction string
---@param selected_text string
---@return string
local function edit_prompt(instruction, selected_text)
	local context = current_context()

	return table.concat({
		"You are editing a Neovim buffer range. Apply the instruction to the selected text.",
		("Output the replacement text wrapped exactly between a line containing only %s and a line containing only %s.")
			:format(REPLACEMENT_OPEN, REPLACEMENT_CLOSE),
		"Put nothing outside those two marker lines. Do not use Markdown fences inside them.",
		"Make the smallest change that satisfies the instruction.",
		"Preserve indentation, style, and line endings implied by the selected text.",
		"Do not include surrounding unchanged file content unless it is part of the replacement range.",
		"If the correct edit removes the range entirely, output the two markers with nothing between them.",
		"",
		("File: %s"):format(context.path),
		("Filetype: %s"):format(context.filetype),
		("Instruction: %s"):format(instruction),
		"",
		"Selected text:",
		"<<<AI_EDIT_SELECTION",
		selected_text,
		"AI_EDIT_SELECTION",
	}, "\n")
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

---Render an inline spinner at the range start while the model is running.
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
				virt_lines = { { { spinner_frames[spinner.frame] .. " Working...", "Comment" } } },
				virt_lines_above = true,
			})

			spinner.frame = (spinner.frame % #spinner_frames) + 1
		end)
	end)

	return spinner
end

---Apply the model's replacement to the marked range.
---@param bufnr integer
---@param edit_range table
---@param start_mark integer
---@param end_mark integer
---@param lines string[] Replacement lines; an empty table deletes the range.
local function apply_replacement(bufnr, edit_range, start_mark, end_mark, lines)
	local start_pos = vim.api.nvim_buf_get_extmark_by_id(bufnr, namespace, start_mark, {})
	local end_pos = vim.api.nvim_buf_get_extmark_by_id(bufnr, namespace, end_mark, {})

	if #start_pos == 0 or #end_pos == 0 then
		notify("Could not find the original edit range.", vim.log.levels.ERROR)
		return
	end

	if edit_range.kind == "text" then
		vim.api.nvim_buf_set_text(bufnr, start_pos[1], start_pos[2], end_pos[1], end_pos[2], lines)
	else
		vim.api.nvim_buf_set_lines(bufnr, start_pos[1], end_pos[1] + 1, false, lines)
	end

	vim.api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)
	notify("Applied AI edit.")
end

---Run an AI edit for the command-provided range.
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

	if vim.fn.executable("claude") ~= 1 then
		notify("The claude CLI is not available on PATH.", vim.log.levels.ERROR)
		return
	end

	local start_mark, end_mark = mark_range(bufnr, edit_range)
	local spinner = start_spinner(bufnr, start_mark)
	local prompt = edit_prompt(instruction, text)

	notify("Asking Claude...")

	vim.system({
		"claude",
		"--print",
		"--allowed-tools",
		"",
	}, {
		text = true,
		stdin = prompt,
	}, function(result)
		local output = result.stdout or ""

		vim.schedule(function()
			if not vim.api.nvim_buf_is_valid(bufnr) then
				stop_spinner(spinner)
				return
			end

			if result.code ~= 0 then
				stop_spinner(spinner)
				local message = vim.trim(result.stderr or result.stdout or "Claude command failed.")
				notify(message, vim.log.levels.ERROR)
				return
			end

			local lines = M.parse_response(output)
			if not lines then
				stop_spinner(spinner)
				notify("Claude did not return a wrapped replacement; buffer left unchanged.", vim.log.levels.ERROR)
				return
			end

			stop_spinner(spinner, true)
			apply_replacement(bufnr, edit_range, start_mark, end_mark, lines)
		end)
	end)
end

---Register the `:AiLine` and `:AiEdit` user commands.
function M.setup()
	vim.api.nvim_create_user_command("AiLine", function(opts)
		local line = vim.api.nvim_win_get_cursor(0)[1]
		M.edit({
			args = opts.args,
			line1 = line,
			line2 = line,
			range = 0,
		})
	end, {
		nargs = "+",
		desc = "Ask Claude to replace the current line",
	})

	vim.api.nvim_create_user_command("AiEdit", function(opts)
		M.edit(opts)
	end, {
		nargs = "+",
		range = true,
		desc = "Ask Claude to replace the selected text",
	})
end

return M
