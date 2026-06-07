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
