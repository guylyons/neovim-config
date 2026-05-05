local ok_alpha, alpha = pcall(require, "alpha")
local ok_dashboard, dashboard = pcall(require, "alpha.themes.dashboard")
if not (ok_alpha and ok_dashboard) then
	return
end

dashboard.section.header.val = {
	[[ ▄████▄   ██▀███   ▄▄▄        ██████  ██░ ██ ]],
	[[▒██▀ ▀█  ▓██ ▒ ██▒▒████▄    ▒██    ▒ ▓██░ ██▒]],
	[[▒▓█    ▄ ▓██ ░▄█ ▒▒██  ▀█▄  ░ ▓██▄   ▒██▀▀██░]],
	[[▒▓▓▄ ▄██▒▒██▀▀█▄  ░██▄▄▄▄██   ▒   ██▒░▓█ ░██ ]],
	[[▒ ▓███▀ ░░██▓ ▒██▒ ▓█   ▓██▒▒██████▒▒░▓█▒░██▓]],
	[[░ ░▒ ▒  ░░ ▒▓ ░▒▓░ ▒▒   ▓▒█░▒ ▒▓▒ ▒ ░ ▒ ░░▒░▒]],
	[[  ░  ▒     ░▒ ░ ▒░  ▒   ▒▒ ░░ ░▒  ░ ░ ▒ ░▒░ ░]],
	[[░          ░░   ░   ░   ▒   ░  ░  ░   ░  ░░ ░]],
	[[░ ░         ░           ░  ░      ░   ░  ░  ░]],
}

dashboard.section.buttons.val = {
	dashboard.button("e", "  New file", ":ene <BAR> startinsert<CR>"),
	dashboard.button("f", "󰈞  Find file", ":lua require('fzf-lua').files()<CR>"),
	dashboard.button("r", "  Recent files", ":lua require('fzf-lua').oldfiles()<CR>"),
	dashboard.button("g", "󰈬  Live grep", ":lua require('fzf-lua').live_grep()<CR>"),
	dashboard.button("c", "  Config", ":lua require('fzf-lua').files({ cwd = vim.fn.stdpath('config') })<CR>"),
	dashboard.button("q", "  Quit", ":qa<CR>"),
}

dashboard.section.footer.val = "Neovim loaded successfully"
dashboard.opts.opts.noautocmd = true
alpha.setup(dashboard.opts)
