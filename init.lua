-- Guy Lyons
-- Custom NeoVim configuration
-- 2026

if vim.loader and vim.loader.enable then
  vim.loader.enable()
end

require("settings")

vim.pack.add({
  "https://github.com/stevearc/conform.nvim",
  "https://github.com/mattn/emmet-vim",
  "https://github.com/ibhagwan/fzf-lua",
  "https://github.com/folke/lazydev.nvim",
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/nvim-lua/plenary.nvim",
  "https://github.com/williamboman/mason.nvim",
  "https://github.com/williamboman/mason-lspconfig.nvim",
  "https://github.com/folke/flash.nvim",
  "https://github.com/lewis6991/gitsigns.nvim",
  { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
  "https://github.com/pmizio/typescript-tools.nvim",
  "https://github.com/folke/which-key.nvim",
})

require("plugins")
require("keybindings")
