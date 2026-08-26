-- A highly efficient, zero-autocmd way to clear hlsearch
local search_keys = { ["<CR>"] = true, n = true, N = true, ["*"] = true, ["#"] = true, ["?"] = true, ["/"] = true }

vim.on_key(function(char)
	if vim.fn.mode() == "n" then
		local new_hlsearch = search_keys[vim.fn.keytrans(char)] or false
		if vim.o.hlsearch ~= new_hlsearch then
			vim.o.hlsearch = new_hlsearch
		end
	end
end, vim.api.nvim_create_namespace("auto-hlsearch"))

vim.api.nvim_create_autocmd("BufReadPost", {
	group = vim.api.nvim_create_augroup("resume-last-edit-position", { clear = true }),
	callback = function()
		local line, col = unpack(vim.api.nvim_buf_get_mark(0, '"'))
		if line > 0 and line <= vim.api.nvim_buf_line_count(0) then
			-- pcall guards against the saved column being past end-of-line
			pcall(vim.api.nvim_win_set_cursor, 0, { line, col })
		end
	end,
})

local fold_group = vim.api.nvim_create_augroup("configure-code-folding", { clear = true })

-- Per-buffer work, once: attaching treesitter and loading the regex syntax are
-- buffer-scoped, so they belong on FileType (fires once when the filetype is set)
-- rather than BufWinEnter (fires on every window/tab switch, re-sourcing syntax).
vim.api.nvim_create_autocmd("FileType", {
	group = fold_group,
	callback = function(args)
		if vim.bo[args.buf].buftype ~= "" then
			return
		end

		-- If treesitter can attach (or is already attached by a plugin), use it.
		if pcall(vim.treesitter.start, args.buf) then
			vim.b[args.buf].ts_folds = true

			-- vim.treesitter.start() turns 'syntax' off, but many runtime indent
			-- scripts -- php, html, css, javascript, lua, sh, ruby, vim -- call
			-- synID() to tell code from strings, comments and heredocs. With no
			-- syntax loaded synID() returns 0 and those scripts silently indent
			-- wrongly (PHP leaves closing braces at column 0). Load the regex
			-- syntax alongside; treesitter highlights still draw on top of it.
			vim.bo[args.buf].syntax = vim.bo[args.buf].filetype
		else
			vim.b[args.buf].ts_folds = false
		end
	end,
})

-- Fold options are window-local, so re-apply them whenever the buffer is shown in
-- a window. This is cheap and idempotent -- no syntax re-sourcing on window switch.
vim.api.nvim_create_autocmd("BufWinEnter", {
	group = fold_group,
	callback = function(args)
		if vim.bo[args.buf].buftype ~= "" then
			return
		end

		if vim.b[args.buf].ts_folds then
			vim.opt_local.foldmethod = "expr"
			vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"
		else
			vim.opt_local.foldmethod = "indent"
			vim.opt_local.foldexpr = "0"
		end
	end,
})

