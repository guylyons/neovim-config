vim.api.nvim_create_autocmd("FileType", {
	pattern = "lua",
	callback = function()
		local ok, lazydev = pcall(require, "lazydev")
		if not ok then
			return
		end

		lazydev.setup({
			library = {
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			},
		})
	end,
})
