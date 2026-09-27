-- Emacs counsel-find-file on top of fzf-lua: list one directory at a time,
-- descend into directories with <CR>, climb with <BS> on an empty query.
local M = {}

-- Directories first (with a trailing slash), then files, each sorted by name.
local function list(dir)
	local dirs, files = {}, {}
	for name, kind in vim.fs.dir(dir) do
		-- Follow symlinks so links to directories stay browsable.
		if kind == "link" then
			local stat = vim.uv.fs_stat(vim.fs.joinpath(dir, name))
			kind = stat and stat.type or kind
		end
		if kind == "directory" then
			table.insert(dirs, name .. "/")
		else
			table.insert(files, name)
		end
	end
	table.sort(dirs)
	table.sort(files)
	local entries = dir == "/" and {} or { "../" }
	return vim.list_extend(vim.list_extend(entries, dirs), files)
end

---@param dir string
function M.open(dir)
	dir = vim.fs.normalize(vim.fn.fnamemodify(dir, ":p"))

	-- `~/...` and `/...` jump elsewhere, as in Emacs; anything else is relative.
	local function resolve(name)
		if name:match("^[~/]") then
			return vim.fs.normalize(name)
		end
		return vim.fs.normalize(vim.fs.joinpath(dir, name))
	end

	-- Directories reopen the picker; anything else, existing or not, is edited.
	local function visit(name)
		if not name or name == "" then
			return
		end
		local path = resolve(name)
		if vim.fn.isdirectory(path) == 1 then
			M.open(path)
		else
			vim.cmd.edit(vim.fn.fnameescape(path))
		end
	end

	local prompt = vim.fn.fnamemodify(dir, ":~")
	require("fzf-lua").fzf_exec(list(dir), {
		prompt = prompt:sub(-1) == "/" and prompt or prompt .. "/",
		cwd = dir,
		fzf_opts = { ["--no-multi"] = true },
		keymap = {
			fzf = {
				-- With no match <CR> still accepts, handing the typed query to the action.
				["enter"] = "accept-or-print-query",
				["backward-eof"] = "print(_up)+accept",
			},
		},
		actions = {
			["enter"] = function(selected, opts)
				visit(selected[1] or opts.last_query)
			end,
			-- Use the query verbatim even when it matches something (counsel's C-M-j).
			["alt-enter"] = function(_, opts)
				visit(opts.last_query)
			end,
			_up = function()
				M.open(vim.fs.dirname(dir))
			end,
		},
	})
end

return M
