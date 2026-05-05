-- Guy Lyons
-- Custom NeoVim configuration
-- 2026

if vim.loader and vim.loader.enable then
	vim.loader.enable()
end

require("env")
require("settings")

vim.pack.add({
	"https://github.com/NeogitOrg/neogit",
	"https://github.com/folke/flash.nvim",
	"https://github.com/folke/which-key.nvim",
	"https://github.com/goolord/alpha-nvim",
	"https://github.com/ibhagwan/fzf-lua",
	"https://github.com/marko-cerovac/material.nvim",
	"https://github.com/mattn/emmet-vim",
	"https://github.com/neovim/nvim-lspconfig",
	"https://github.com/nvim-lua/plenary.nvim",
	"https://github.com/nvim-tree/nvim-web-devicons",
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
	"https://github.com/pmizio/typescript-tools.nvim",
	"https://github.com/s1n7ax/nvim-window-picker",
	"https://github.com/sindrets/diffview.nvim",
	"https://github.com/williamboman/mason-lspconfig.nvim",
	"https://github.com/williamboman/mason.nvim",
})

require("plugins")
require("keybindings")
