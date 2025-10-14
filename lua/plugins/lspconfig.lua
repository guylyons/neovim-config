return {
	"neovim/nvim-lspconfig",
	dependencies = {
		{
			"folke/lazydev.nvim",
			ft = "lua",
			opts = {
				library = {
					-- See the configuration section for more details
					-- Load luvit types when the `vim.uv` word is found
					{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
				},
			},
		},
	},
	config = function()
		-- Lua language server setup
		vim.lsp.enable("lua_ls")
		-- Python
		vim.lsp.enable("pyright")
		-- Bash
		vim.lsp.enable("bashls")

		vim.diagnostic.config({
			virtual_text = true,
			signs = false,
			underline = false,
			update_in_insert = false,
		})
	end,
}
