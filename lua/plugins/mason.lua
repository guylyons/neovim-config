return {
	"williamboman/mason.nvim",
	dependencies = { "williamboman/mason-lspconfig.nvim" },
	config = function()
		require("mason").setup()
		require("mason-lspconfig").setup({
			ensure_installed = {
				"bashls",
				"cssls",
				"emmet_language_server",
				"html",
				"jsonls",
				"lua_ls",
				"phpactor",
				"pyright",
				"yamlls",
			},
			automatic_enable = {
				exclude = { "ts_ls" },
			},
		})
	end,
}
