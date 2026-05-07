local ok_mason, mason = pcall(require, "mason")
local ok_mason_lsp, mason_lspconfig = pcall(require, "mason-lspconfig")
if not (ok_mason and ok_mason_lsp) then
	return
end

mason.setup()
mason_lspconfig.setup({
	ensure_installed = {
		"bashls",
		"cssls",
		"emmet_language_server",
		"html",
		"intelephense",
		"jsonls",
		"lua_ls",
		"pyright",
		"yamlls",
	},
	automatic_enable = false,
})
