-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Folds with Tree-sitter
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldenable = true  -- Enable folding
vim.opt.foldlevel = 1   -- Expand all folds by default

vim.opt.relativenumber = true -- Show relative line numbers
vim.opt.number = true         -- Show the current line's absolute number

