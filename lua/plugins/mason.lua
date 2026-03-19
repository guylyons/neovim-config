return {
	"williamboman/mason.nvim",
	dependencies = { "williamboman/mason-lspconfig.nvim" },
	config = function()
		if #vim.api.nvim_list_uis() == 0 then
			return
		end

		require("mason").setup()
		require("mason-lspconfig").setup({
			ensure_installed = {
				"phpactor",
			},
			automatic_enable = {
				exclude = { "ts_ls" },
			},
		})
	end,
}
