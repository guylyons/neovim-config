-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading plugins so that mappings are correct.
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.opt.wrap = false
vim.opt.termguicolors = true

if vim.fn.executable("rg") == 1 then
	vim.opt.grepprg = "rg --vimgrep --smart-case"
	vim.opt.grepformat = "%f:%l:%c:%m,%f:%l:%m"
end

-- Fold code by default, preferring Tree-sitter and falling back to indent rules.
vim.opt.foldenable = true
vim.opt.foldlevel = 1
vim.opt.foldlevelstart = 1
vim.opt.foldminlines = 6
vim.opt.foldnestmax = 3
vim.opt.foldcolumn = "0"

vim.opt.relativenumber = true
vim.opt.number = true
vim.opt.signcolumn = "yes"

-- Clipboard
vim.opt.clipboard = "unnamedplus"

-- General indentation settings
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.smartindent = true
vim.opt.autoindent = true

-- Search highlight fix
-- Turns off keyword highlighting after cursor movement.
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
	group = vim.api.nvim_create_augroup("resume-last-edit-position", { clear = true }),
	callback = function()
		local mark = vim.api.nvim_buf_get_mark(0, '"')
		local line = mark[1]
		local col = mark[2]
		if line > 0 and line <= vim.api.nvim_buf_line_count(0) then
			vim.api.nvim_win_set_cursor(0, { line, col })
		end
	end,
})

local function configure_code_folding(bufnr)
	if vim.bo[bufnr].buftype ~= "" then
		return
	end

	local winid = vim.fn.bufwinid(bufnr)
	if winid == -1 then
		return
	end

	if pcall(vim.treesitter.start, bufnr) then
		vim.wo[winid].foldmethod = "expr"
		vim.wo[winid].foldexpr = "v:lua.vim.treesitter.foldexpr()"
		return
	end

	vim.wo[winid].foldmethod = "indent"
	vim.wo[winid].foldexpr = "0"
end

vim.api.nvim_create_autocmd({ "BufWinEnter", "FileType" }, {
	group = vim.api.nvim_create_augroup("configure-code-folding", { clear = true }),
	callback = function(args)
		configure_code_folding(args.buf)
	end,
})

vim.filetype.add({
	extension = {
		twig = "twig",
		module = "php",
		theme = "php",
		install = "php",
		profile = "php",
		info = "dosini",
	},
	pattern = {
		[".*%.info%.yml"] = "yaml",
		[".*%.services%.yml"] = "yaml",
		[".*%.routing%.yml"] = "yaml",
		[".*%.links%..*%.yml"] = "yaml",
		[".*%.libraries%.yml"] = "yaml",
		[".*%.permissions%.yml"] = "yaml",
		[".*%.schema%.yml"] = "yaml",
	},
})

_G.TwigIndent = function()
	local indent = 0
	if vim.fn.exists("*HtmlIndent") == 1 then
		indent = vim.fn["HtmlIndent"]()
	else
		local prev = vim.fn.prevnonblank(vim.v.lnum - 1)
		indent = prev > 0 and vim.fn.indent(prev) or 0
	end

	local line = vim.fn.getline(vim.v.lnum)
	if
		line:match("^%s*{%-?%s*end")
		or line:match("^%s*{%-?%s*else")
		or line:match("^%s*{%-?%s*elseif")
		or line:match("^%s*{%-?%s*elif")
	then
		local sw = vim.bo.shiftwidth
		indent = math.max(indent - sw, 0)
	end

	return indent
end

vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("twig-indent", { clear = true }),
	pattern = "twig",
	callback = function()
		-- Base Twig indent on HTML rules, with small Twig-aware adjustments.
		vim.cmd("runtime! indent/html.vim")
		vim.bo.indentexpr = "v:lua.TwigIndent()"
	end,
})
