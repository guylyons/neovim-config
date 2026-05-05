local ok, fzf = pcall(require, "fzf-lua")
if not ok then
	return
end

fzf.setup({
	"max-perf",

	grep = {
		previewer = false,
		file_icons = false,
		git_icons = false,
		color_icons = false,
		rg_glob = false,
		rg_opts = table.concat({
			"--hidden",
			"--column",
			"--line-number",
			"--no-heading",
			"--color=never",
			"--smart-case",
			"--max-columns=4096",
			"-g",
			"'!.git'",
			"-g",
			"'!.jj'",
			"-g",
			"'!node_modules'",
			"-g",
			"'!vendor'",
			"-g",
			"'!var/cache'",
			"-g",
			"'!web/sites/*/files'",
			"-g",
			"'!docroot/sites/*/files'",
			"-e",
		}, " "),
	},

	winopts = {
		preview = {
			hidden = true,
		},
	},

	fzf_opts = {
		["--ansi"] = false,
		["--layout"] = "reverse",
		["--info"] = "inline",
	},
})
