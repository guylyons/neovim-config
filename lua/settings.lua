local function prepend_path(path)
	if not path or path == "" or vim.fn.isdirectory(path) == 0 then
		return
	end

	local path_entries = vim.split(vim.env.PATH or "", ":", { plain = true, trimempty = true })
	if vim.tbl_contains(path_entries, path) then
		return
	end

	vim.env.PATH = path .. ":" .. (vim.env.PATH or "")
end

local function parse_version(version)
	local major, minor, patch = version:match("^v?(%d+)%.?(%d*)%.?(%d*)$")
	return tonumber(major) or -1, tonumber(minor) or -1, tonumber(patch) or -1
end

local function version_greater(a, b)
	local a_major, a_minor, a_patch = parse_version(a)
	local b_major, b_minor, b_patch = parse_version(b)

	if a_major ~= b_major then
		return a_major > b_major
	end
	if a_minor ~= b_minor then
		return a_minor > b_minor
	end

	return a_patch > b_patch
end

local function find_nvm_node_bin()
	local home = vim.env.HOME
	if not home or home == "" then
		return nil
	end

	local nvm_dir = vim.fs.joinpath(home, ".nvm")
	local versions_dir = vim.fs.joinpath(nvm_dir, "versions", "node")
	if vim.fn.isdirectory(versions_dir) == 0 then
		return nil
	end

	local alias_file = vim.fs.joinpath(nvm_dir, "alias", "default")
	local alias = nil
	if vim.fn.filereadable(alias_file) == 1 then
		alias = vim.trim(table.concat(vim.fn.readfile(alias_file), "\n"))
	end

	local all_versions = {}
	local matching_versions = {}
	for name, kind in vim.fs.dir(versions_dir) do
		if kind == "directory" then
			table.insert(all_versions, name)
			if alias and alias ~= "" and (name == alias or vim.startswith(name, alias .. ".")) then
				table.insert(matching_versions, name)
			end
		end
	end

	local versions = #matching_versions > 0 and matching_versions or all_versions
	if #versions == 0 then
		return nil
	end

	table.sort(versions, version_greater)
	return vim.fs.joinpath(versions_dir, versions[1], "bin")
end

if vim.fn.executable("node") == 0 or vim.fn.executable("npm") == 0 then
	prepend_path("/opt/homebrew/bin")
	prepend_path("/opt/homebrew/sbin")
	prepend_path(find_nvm_node_bin())
end

local function prefer_builtin_parser(lang)
	local runtime = vim.env.VIMRUNTIME
	if not runtime or runtime == "" then
		return
	end

	local nvim_root = vim.fn.fnamemodify(runtime, ":h:h:h")
	local parser_path = vim.fs.joinpath(nvim_root, "lib", "nvim", "parser", lang .. ".so")
	if vim.uv.fs_stat(parser_path) then
		pcall(vim.treesitter.language.add, lang, { path = parser_path })
	end
end

prefer_builtin_parser("lua")
prefer_builtin_parser("markdown")
prefer_builtin_parser("markdown_inline")
prefer_builtin_parser("query")
prefer_builtin_parser("vim")
prefer_builtin_parser("vimdoc")

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading plugins so that mappings are correct.
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.opt.wrap = false
vim.opt.termguicolors = true
pcall(vim.cmd, "packadd nvim.undotree")

if vim.fn.executable("rg") == 1 then
	vim.opt.grepprg = "rg --vimgrep --smart-case"
	vim.opt.grepformat = "%f:%l:%c:%m,%f:%l:%m"
end

-- Folds with Tree-sitter
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldenable = false
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99

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
