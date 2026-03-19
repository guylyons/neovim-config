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
	local alias
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

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.opt.autoindent = true
vim.opt.clipboard = "unnamedplus"
vim.opt.expandtab = true
vim.opt.foldenable = true
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldmethod = "expr"
vim.opt.ignorecase = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.shiftwidth = 2
vim.opt.signcolumn = "yes"
vim.opt.smartcase = true
vim.opt.smartindent = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.tabstop = 2
vim.opt.termguicolors = true
vim.opt.undofile = true
vim.opt.updatetime = 250
vim.opt.wrap = false

vim.filetype.add({
	extension = {
		install = "php",
		module = "php",
		profile = "php",
		theme = "php",
		twig = "twig",
	},
	pattern = {
		[".*%.info%.yml"] = "yaml",
		[".*%.links%..*%.yml"] = "yaml",
		[".*%.routing%.yml"] = "yaml",
		[".*%.services%.yml"] = "yaml",
	},
})

local autocmd_group = vim.api.nvim_create_augroup("user-settings", { clear = true })
vim.api.nvim_create_autocmd("CursorMoved", {
	group = autocmd_group,
	callback = function()
		if vim.v.hlsearch == 1 and vim.fn.searchcount().exact_match == 0 then
			vim.schedule(function()
				vim.cmd.nohlsearch()
			end)
		end
	end,
})

vim.api.nvim_create_autocmd("BufReadPost", {
	group = autocmd_group,
	callback = function()
		local mark = vim.api.nvim_buf_get_mark(0, '"')
		local line = mark[1]
		local col = mark[2]
		if line > 0 and line <= vim.api.nvim_buf_line_count(0) then
			vim.api.nvim_win_set_cursor(0, { line, col })
		end
	end,
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
	if line:match("^%s*{%-?%s*end") or line:match("^%s*{%-?%s*else") or line:match("^%s*{%-?%s*elseif") or line:match("^%s*{%-?%s*elif") then
		local sw = vim.bo.shiftwidth
		indent = math.max(indent - sw, 0)
	end

	return indent
end

vim.api.nvim_create_autocmd("FileType", {
	group = autocmd_group,
	pattern = "twig",
	callback = function()
		vim.cmd("runtime! indent/html.vim")
		vim.bo.indentexpr = "v:lua.TwigIndent()"
	end,
})
