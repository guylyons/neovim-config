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

