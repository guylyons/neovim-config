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
		local function enable_when_available(server_name, command)
			if vim.fn.executable(command) == 1 then
				vim.lsp.enable(server_name)
			end
		end

		enable_when_available("lua_ls", "lua-language-server")
		enable_when_available("pyright", "pyright-langserver")
		enable_when_available("bashls", "bash-language-server")
		enable_when_available("phpactor", "phpactor")
		enable_when_available("emmet_language_server", "emmet-language-server")
		enable_when_available("yaml_language_server", "yaml-language-server")

		if vim.fn.executable("drupal_ls") == 1 then
			vim.lsp.config.drupal_ls = {
				cmd = { "drupal_ls" },
				filetypes = { "php", "twig", "yaml" },
				root_markers = { "composer.json", ".git" },
			}
			vim.lsp.enable("drupal_ls")
		end

		vim.diagnostic.config({
			virtual_text = true,
			signs = false,
			underline = false,
			update_in_insert = false,
		})
	end,
}
