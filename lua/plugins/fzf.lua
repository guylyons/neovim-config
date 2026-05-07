local ok, fzf = pcall(require, "fzf-lua")
if not ok then
	return
end

fzf.setup({
	fzf_opts = {
		["--ansi"] = true,
	},

	grep = {
		rg_opts = table.concat({
			"--column",
			"--line-number",
			"--no-heading",
			"--color=always",
			"--smart-case",
			"--hidden",
			"--glob '!**/.git/**'",
		}, " "),
	},

	previewers = {
		bat = {
			cmd = "bat",
			args = "--style=numbers,changes --color=always",
		},
	},
})
