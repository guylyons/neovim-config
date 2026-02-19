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

		-- PHP/Drupal
		vim.lsp.enable("phpactor")

		-- Emmet
		vim.lsp.enable("emmet_language_server")

		-- YAML (Drupal .yml files)
		vim.lsp.enable("yaml_language_server")

		-- Custom: Drupal Language Server (requires manual installation)
		vim.lsp.config.drupal_ls = {
			cmd = { "drupal_ls" },
			filetypes = { "php", "twig", "yaml" },
			root_markers = { "composer.json", ".git" },
		}
		vim.lsp.enable("drupal_ls")

		vim.diagnostic.config({
			virtual_text = true,
			signs = false,
			underline = false,
			update_in_insert = false,
		})
	end,
}
