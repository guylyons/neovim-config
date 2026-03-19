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
		local capabilities = vim.lsp.protocol.make_client_capabilities()
		local has_cmp_nvim_lsp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
		if has_cmp_nvim_lsp then
			capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
		end

		vim.lsp.config("*", {
			capabilities = capabilities,
		})

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
			vim.lsp.config("drupal_ls", {
				cmd = { "drupal_ls" },
				filetypes = { "php", "twig", "yaml" },
				root_markers = { "composer.json", ".git" },
			})
			vim.lsp.enable("drupal_ls")
		end

		vim.diagnostic.config({
			virtual_text = true,
			signs = false,
			underline = false,
			update_in_insert = false,
		})

		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("user-lsp-attach", { clear = true }),
			callback = function(event)
				local map = function(lhs, rhs, desc, mode)
					vim.keymap.set(mode or "n", lhs, rhs, {
						buffer = event.buf,
						desc = desc,
					})
				end

				map("gd", vim.lsp.buf.definition, "Go to definition")
				map("gD", vim.lsp.buf.declaration, "Go to declaration")
				map("gr", vim.lsp.buf.references, "List references")
				map("gi", vim.lsp.buf.implementation, "Go to implementation")
				map("K", vim.lsp.buf.hover, "Hover")
				map("<leader>rn", vim.lsp.buf.rename, "Rename symbol")
				map("<leader>ca", vim.lsp.buf.code_action, "Code action", { "n", "v" })
			end,
		})
	end,
}
