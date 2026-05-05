local ok, typescript_tools = pcall(require, "typescript-tools")
if not ok then
	return
end

typescript_tools.setup({
	complete_function_calls = true,
	include_completions_with_insert_text = true,
	jsx_close_tag = {
		enable = true,
		filetypes = { "javascriptreact", "typescriptreact" },
	},
	settings = {
		separate_diagnostic_server = false,
		publish_diagnostic_on = "change",
		expose_as_code_action = {
			"add_missing_imports",
			"remove_unused",
			"organize_imports",
			"fix_all",
		},
		tsserver_max_memory = "auto",
		tsserver_file_preferences = {
			includeCompletionsForImportStatements = true,
			includeCompletionsForModuleExports = true,
			includeCompletionsWithInsertText = true,
			includeCompletionsWithSnippetText = true,
			includeAutomaticOptionalChainCompletions = true,
			includePackageJsonAutoImports = "auto",
			jsxAttributeCompletionStyle = "auto",
			quotePreference = "double",
			importModuleSpecifierPreference = "non-relative",
			includeInlayParameterNameHints = "all",
			includeInlayParameterNameHintsWhenArgumentMatchesName = false,
			includeInlayFunctionParameterTypeHints = true,
			includeInlayVariableTypeHints = true,
			includeInlayVariableTypeHintsWhenTypeMatchesName = false,
			includeInlayPropertyDeclarationTypeHints = true,
			includeInlayFunctionLikeReturnTypeHints = true,
			includeInlayEnumMemberValueHints = true,
		},
		tsserver_format_options = {
			allowIncompleteCompletions = false,
			allowRenameOfImportPath = false,
		},
	},
})

local ts_filetypes = {
	javascript = true,
	javascriptreact = true,
	typescript = true,
	typescriptreact = true,
	tsx = true,
	jsx = true,
}

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("typescript-inlay-hints", { clear = true }),
	callback = function(args)
		local ft = vim.bo[args.buf].filetype
		if not ts_filetypes[ft] then
			return
		end

		if vim.lsp.get_client_by_id(args.data.client_id) then
			pcall(vim.lsp.inlay_hint.enable, true, { bufnr = args.buf })
		end
	end,
})
