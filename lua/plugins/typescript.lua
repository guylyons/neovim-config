return {
	"pmizio/typescript-tools.nvim",
	dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
	enabled = function()
		return vim.fn.executable("node") == 1
	end,
	config = function()
		local capabilities = vim.lsp.protocol.make_client_capabilities()
		local has_cmp_nvim_lsp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
		if has_cmp_nvim_lsp then
			capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
		end

		require("typescript-tools").setup({
			capabilities = capabilities,
		})
	end,
}
