--- Inline range-edit integration backed by the Codex CLI.
--- 2026

---Read Codex's clean final-message file, falling back to stdout.
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

return require("core.inline_edit").create({
	title = "Codex",
	vendor = "Codex",
	executable = "codex",
	commands = {
		line = { name = "CodexLine", desc = "Ask Codex to replace the current line" },
		edit = { name = "CodexEdit", desc = "Ask Codex to replace the selected text" },
	},
	---Run `codex exec` read-only, feeding the prompt on stdin and reading the clean
	---final message from a temp file (falling back to stdout).
	---@param prompt string
	---@param done fun(result: { code: integer, output: string, stderr: string? })
	run = function(prompt, done)
		local output_file = vim.fn.tempname()

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
			pcall(vim.uv.fs_unlink, output_file)
			done({ code = result.code, output = output, stderr = result.stderr })
		end)
	end,
})
