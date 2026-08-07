-- TypeScript 7 ships a native (Go) language server instead of the old
-- `typescript/lib/tsserver.js`. It is exposed as `tsgo` by
-- @typescript/native-preview and as `tsc` by the `typescript` package itself.
-- nvim-lspconfig provides `lsp/tsgo.lua` (monorepo + Deno aware root_dir);
-- we inherit that and only override how the binary is located, plus settings.

local function ts_major(root_dir)
	local package_json = root_dir .. "/node_modules/typescript/package.json"
	local ok, contents = pcall(vim.fn.readfile, package_json)
	if not ok or vim.tbl_isempty(contents) then
		return nil
	end

	local decoded_ok, decoded = pcall(vim.json.decode, table.concat(contents, "\n"))
	if not decoded_ok or type(decoded) ~= "table" or type(decoded.version) ~= "string" then
		return nil
	end

	return tonumber(decoded.version:match("^(%d+)"))
end

-- Prefer a project-local server, then a global one. `tsgo` is unambiguous;
-- `tsc` only speaks LSP from TypeScript 7 onwards, so gate the local one on
-- the installed major version.
local function resolve_cmd(root_dir)
	local local_tsgo = root_dir and (root_dir .. "/node_modules/.bin/tsgo")
	if local_tsgo and vim.fn.executable(local_tsgo) == 1 then
		return local_tsgo
	end

	local local_tsc = root_dir and (root_dir .. "/node_modules/.bin/tsc")
	if local_tsc and vim.fn.executable(local_tsc) == 1 then
		local major = ts_major(root_dir)
		if major and major >= 7 then
			return local_tsc
		end
	end

	if vim.fn.executable("tsgo") == 1 then
		return "tsgo"
	end

	return "tsc"
end

-- tsgo namespaces identical settings under `typescript` and `javascript`.
local function language_settings(extra_preferences)
	return {
		inlayHints = {
			parameterNames = {
				enabled = "all",
				suppressWhenArgumentMatchesName = true,
			},
			parameterTypes = { enabled = true },
			variableTypes = {
				enabled = true,
				suppressWhenTypeMatchesName = true,
			},
			propertyDeclarationTypes = { enabled = true },
			functionLikeReturnTypes = { enabled = true },
			enumMemberValues = { enabled = true },
		},
		preferences = vim.tbl_extend("force", {
			quoteStyle = "double",
			importModuleSpecifier = "non-relative",
		}, extra_preferences or {}),
		suggest = {
			completeFunctionCalls = true,
			autoImports = true,
			includeCompletionsForImportStatements = true,
		},
	}
end

vim.lsp.config("tsgo", {
	cmd = function(dispatchers, config)
		local root_dir = (config or {}).root_dir
		return vim.lsp.rpc.start({ resolve_cmd(root_dir), "--lsp", "--stdio" }, dispatchers)
	end,
	settings = {
		typescript = language_settings({ includePackageJsonAutoImports = "auto" }),
		javascript = language_settings(),
	},
})

if vim.fn.executable("tsgo") == 1 or vim.fn.executable("tsc") == 1 then
	vim.lsp.enable("tsgo")
end

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("typescript-inlay-hints", { clear = true }),
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if client and client.name == "tsgo" and client:supports_method("textDocument/inlayHint") then
			vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
		end
	end,
})
