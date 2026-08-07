-- Optional: fzf-lua renders file icons only when devicons is present.
pcall(require, "nvim-web-devicons")

require("fzf-lua").setup({
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
