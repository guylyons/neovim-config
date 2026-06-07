-- A highly efficient, zero-autocmd way to clear hlsearch
vim.on_key(function(char)
	if vim.fn.mode() == "n" then
		local new_hlsearch = vim.tbl_contains({ "<CR>", "n", "N", "*", "#", "?", "/" }, vim.fn.keytrans(char))
		if vim.opt.hlsearch:get() ~= new_hlsearch then
			vim.opt.hlsearch = new_hlsearch
		end
	end
end, vim.api.nvim_create_namespace("auto-hlsearch"))

vim.api.nvim_create_autocmd("BufReadPost", {
	group = vim.api.nvim_create_augroup("resume-last-edit-position", { clear = true }),
	callback = function()
		local mark = vim.api.nvim_buf_get_mark(0, '"')
		local line = mark[1]
		local col = mark[2]
		if line > 0 and line <= vim.api.nvim_buf_line_count(0) then
			-- Use pcall to prevent errors if the column is out of bounds
			pcall(vim.api.nvim_win_set_cursor, 0, { line, col })
		end
	end,
})

vim.api.nvim_create_autocmd({ "BufWinEnter", "FileType" }, {
	group = vim.api.nvim_create_augroup("configure-code-folding", { clear = true }),
	callback = function(args)
		if vim.bo[args.buf].buftype ~= "" then
			return
		end

		-- If treesitter can attach (or is already attached by a plugin), use it
		if pcall(vim.treesitter.start, args.buf) then
			-- Use vim.opt_local to safely set options for the current window/buffer
			vim.opt_local.foldmethod = "expr"
			vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"
		else
			-- Fallback
			vim.opt_local.foldmethod = "indent"
			vim.opt_local.foldexpr = "0"
		end
	end,
})

