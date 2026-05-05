vim.pack.add({
	"https://github.com/NeogitOrg/neogit",
	"https://github.com/folke/flash.nvim",
	"https://github.com/folke/which-key.nvim",
	"https://github.com/goolord/alpha-nvim",
	"https://github.com/ibhagwan/fzf-lua",
	"https://github.com/marko-cerovac/material.nvim",
	"https://github.com/mattn/emmet-vim",
	"https://github.com/neovim/nvim-lspconfig",
	"https://github.com/nvim-tree/nvim-web-devicons",
	"https://github.com/pmizio/typescript-tools.nvim",
	"https://github.com/s1n7ax/nvim-window-picker",
	"https://github.com/sindrets/diffview.nvim",
	"https://github.com/williamboman/mason-lspconfig.nvim",
	"https://github.com/williamboman/mason.nvim",
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
})

local function notify_error(message)
	vim.schedule(function()
		vim.notify(message, vim.log.levels.ERROR)
	end)
end

-- Require Neovim 0.12+
if vim.fn.has("nvim-0.12") == 0 then
	notify_error("This config requires Neovim 0.12+ (vim.pack).")
	return
end

-- Safe module loader
local function load_module(module_name)
	local ok, err = pcall(require, module_name)
	if not ok then
		notify_error(("Failed to load %s: %s"):format(module_name, err))
	end
	return ok
end

-- Load plugins
local plugin_modules = {
	"plugins.alpha",
	"plugins.emmet",
	"plugins.flash",
	"plugins.fzf",
	"plugins.gitsigns",
	"plugins.lspconfig",
	"plugins.mason",
	"plugins.material",
	"plugins.neogit",
	"plugins.nvim-window-picker",
	"plugins.typescript",
	"plugins.whichkey",
}

for _, module_name in ipairs(plugin_modules) do
	load_module(module_name)
end
