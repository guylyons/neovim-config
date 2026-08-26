--- Inline AI range-edit integration backed by the Claude CLI.
--- 2026
return require("core.inline_edit").create({
	title = "AI Edit",
	vendor = "Claude",
	executable = "claude",
	commands = {
		line = { name = "AiLine", desc = "Ask Claude to replace the current line" },
		edit = { name = "AiEdit", desc = "Ask Claude to replace the selected text" },
	},
	---Run Claude in print mode, feeding the prompt on stdin and reading the reply
	---from stdout. Tools are disabled since this is a pure text transformation.
	---@param prompt string
	---@param done fun(result: { code: integer, output: string, stderr: string? })
	run = function(prompt, done)
		vim.system({
			"claude",
			"--print",
			"--allowed-tools",
			"",
		}, {
			text = true,
			stdin = prompt,
		}, function(result)
			done({ code = result.code, output = result.stdout or "", stderr = result.stderr })
		end)
	end,
})
