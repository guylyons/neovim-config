vim.pack.add({
	"https://github.com/NeogitOrg/neogit",
	"https://github.com/yannvanhalewyn/jujutsu.nvim",
	"https://github.com/L3MON4D3/LuaSnip",
	"https://github.com/lewis6991/gitsigns.nvim",
	"https://github.com/hrsh7th/cmp-buffer",
	"https://github.com/hrsh7th/cmp-nvim-lsp",
	"https://github.com/hrsh7th/cmp-path",
	"https://github.com/hrsh7th/nvim-cmp",
	"https://github.com/nvim-lua/plenary.nvim",
	"https://github.com/saadparwaiz1/cmp_luasnip",
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
	"https://github.com/rachartier/tiny-inline-diagnostic.nvim",
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
	"plugins.treesitter",
	"plugins.alpha",
	"plugins.emmet",
	"plugins.flash",
	"plugins.format",
	"plugins.fzf",
	"plugins.gitsigns",
	"plugins.go",
	"plugins.mason",
	"plugins.material",
	"plugins.jujutsu",
	"plugins.neogit",
	"plugins.nvim-window-picker",
	"plugins.completion",
	"plugins.lsp",
	"plugins.php",
	"plugins.typescript",
	"plugins.whichkey",
	"plugins.tiny",
}

for _, module_name in ipairs(plugin_modules) do
	load_module(module_name)
end
