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

		local function create_lsp_compat_command(name, callback, desc)
			if vim.fn.exists(":" .. name) == 0 then
				vim.api.nvim_create_user_command(name, callback, { desc = desc })
			end
		end

		create_lsp_compat_command("LspInfo", function()
			vim.cmd("checkhealth vim.lsp")
		end, "Show LSP info")

		create_lsp_compat_command("LspRestart", function()
			vim.cmd("lsp restart")
		end, "Restart LSP clients")

		create_lsp_compat_command("LspLog", function()
			local log_path = vim.fs.joinpath(vim.fn.stdpath("state"), "lsp.log")
			vim.cmd("edit " .. vim.fn.fnameescape(log_path))
		end, "Show LSP log")

		enable_when_available("lua_ls", "lua-language-server")
		enable_when_available("pyright", "pyright-langserver")
		enable_when_available("bashls", "bash-language-server")
		enable_when_available("phpactor", "phpactor")
		enable_when_available("emmet_language_server", "emmet-language-server")
		enable_when_available("yamlls", "yaml-language-server")

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
