local alpha = require("alpha")
local dashboard = require("alpha.themes.dashboard")

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
	dashboard.button("a", "󰚩  Claude", ":ClaudeCode<CR>"),
	dashboard.button("c", "  Config", ":lua require('fzf-lua').files({ cwd = vim.fn.stdpath('config') })<CR>"),
	dashboard.button("q", "  Quit", ":qa<CR>"),
}

-- Built lazily: this module loads before shada populates v:oldfiles.
local function recent_files()
	local buttons = {}
	for _, path in ipairs(vim.v.oldfiles) do
		if #buttons == 9 then
			break
		end
		if vim.fn.filereadable(path) == 1 and not path:match("COMMIT_EDITMSG$") then
			local key = tostring(#buttons + 1)
			local name = vim.fn.fnamemodify(path, ":~:.")
			-- Keep the tail of long paths so they fit the button column.
			if vim.fn.strchars(name) > 40 then
				name = "…" .. vim.fn.strcharpart(name, vim.fn.strchars(name) - 39)
			end
			local icon = require("nvim-web-devicons").get_icon(path, nil, { default = true })
			local button = dashboard.button(key, icon .. "  " .. name, ":e " .. vim.fn.fnameescape(path) .. "<CR>")
			button.opts.hl = "Comment"
			table.insert(buttons, button)
		end
	end
	return buttons
end

local recent = {
	type = "group",
	val = {
		{ type = "text", val = "Recent files", opts = { hl = "SpecialComment", position = "center" } },
		{ type = "padding", val = 1 },
		{ type = "group", val = recent_files, opts = { spacing = 0 } },
	},
}

dashboard.opts.layout = {
	{ type = "padding", val = 2 },
	dashboard.section.header,
	{ type = "padding", val = 2 },
	dashboard.section.buttons,
	{ type = "padding", val = 1 },
	recent,
	{ type = "padding", val = 1 },
	dashboard.section.footer,
}

dashboard.section.footer.val = "Neovim loaded successfully"
dashboard.opts.opts.noautocmd = true
alpha.setup(dashboard.opts)
