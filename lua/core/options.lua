vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.opt.wrap = false
vim.opt.termguicolors = true

-- Never show the tabline. Neogit and diffview open in their own tabpages, which
-- would otherwise pop a "[Scratch]" tab bar above the window.
vim.opt.showtabline = 0

if vim.fn.executable("rg") == 1 then
	vim.opt.grepprg = "rg --vimgrep --smart-case"
	vim.opt.grepformat = "%f:%l:%c:%m,%f:%l:%m"
end

vim.opt.foldenable = true
vim.opt.foldlevel = 1
vim.opt.foldlevelstart = 1
vim.opt.foldminlines = 6
vim.opt.foldnestmax = 3
vim.opt.foldcolumn = "0"

vim.opt.relativenumber = true
vim.opt.number = true
vim.opt.signcolumn = "yes"

vim.opt.clipboard = "unnamedplus"

vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.cindent = false
