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

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.opt.wrap = false

-- Folds with Tree-sitter
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
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
