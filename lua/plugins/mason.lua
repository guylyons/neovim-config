return {
	"williamboman/mason.nvim",
	dependencies = { "williamboman/mason-lspconfig.nvim" },
	config = function()
		require("mason").setup()
		require("mason-lspconfig").setup({
			ensure_installed = {
				"phpactor",
				"yamlls",
			},
			automatic_enable = {
				exclude = { "ts_ls" },
			},
		})
	end,
}
