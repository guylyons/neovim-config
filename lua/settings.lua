-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Folds with Tree-sitter
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.get_fold_indic(0)"
vim.opt.foldenable = true -- Enable folding
vim.opt.foldlevel = 1 -- Expand all folds by default

vim.opt.relativenumber = true -- Show relative line numbers
vim.opt.number = true -- Show the current line's absolute number

-- Clipboard
vim.opt.clipboard = "unnamedplus"

-- General indentation settings
vim.opt.expandtab = true -- Use spaces instead of tabs
vim.opt.shiftwidth = 2 -- Number of spaces for each indentation level
vim.opt.tabstop = 2 -- Number of spaces for a tab character
vim.opt.smartindent = true -- Automatically indent new lines
vim.opt.autoindent = true -- Copy indentation from the previous line

-- Search highlight fix
-- turns off keyword highlighting after cursor movement
vim.api.nvim_create_autocmd("CursorMoved", {
	group = vim.api.nvim_create_augroup("auto-hlsearch", { clear = true }),
	callback = function()
		if vim.v.hlsearch == 1 and vim.fn.searchcount().exact_match == 0 then
			vim.schedule(function()
				vim.cmd.nohlsearch()
			end)
		end
	end,
})

-- Automatically return to the last editing position when reopening a file
vim.api.nvim_create_autocmd("BufReadPost", {
	callback = function()
		local mark = vim.api.nvim_buf_get_mark(0, '"')
		local line = mark[1]
		local col = mark[2]
		if line > 0 and line <= vim.api.nvim_buf_line_count(0) then
			vim.api.nvim_win_set_cursor(0, { line, col })
		end
	end,
})

vim.opt.runtimepath:append(vim.fn.stdpath("config") .. "/lua")

-- Filetype detection for Twig
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	pattern = "*.twig",
	callback = function()
		vim.bo.filetype = "twig"
	end,
})

-- Drupal filetype detection
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	pattern = {
		"*.module",
		"*.theme",
		"*.install",
		"*.profile",
		"*.info",
		"*.routing.yml",
		"*.services.yml",
		"*.links.*.yml",
	},
	callback = function()
		vim.bo.filetype = "php"
	end,
})
