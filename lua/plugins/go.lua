local go_filetypes = {
	go = true,
	gomod = true,
	gowork = true,
	gotmpl = true,
}

local format_group = vim.api.nvim_create_augroup("go-format-on-save", { clear = false })

vim.lsp.config("gopls", {
	settings = {
		gopls = {
			gofumpt = true,
			staticcheck = true,
			usePlaceholders = true,
			analyses = {
				fieldalignment = true,
				nilness = true,
				shadow = true,
				unusedparams = true,
				unusedwrite = true,
			},
		},
	},
})

local function organize_imports(bufnr)
	local clients = vim.lsp.get_clients({ bufnr = bufnr, name = "gopls" })
	local client = clients[1]
	if not client or not client:supports_method("textDocument/codeAction") then
		return
	end

	local position_encoding = client.offset_encoding or "utf-16"
	local params = vim.lsp.util.make_range_params(0, position_encoding)
	params.context = {
		only = { "source.organizeImports" },
		diagnostics = {},
	}

	local response = client:request_sync("textDocument/codeAction", params, 2000, bufnr)
	if not response or response.err or not response.result then
		return
	end

	for _, action in ipairs(response.result) do
		if action.edit then
			vim.lsp.util.apply_workspace_edit(action.edit, position_encoding)
		end

		if type(action.command) == "table" then
			client:exec_cmd(action.command, { bufnr = bufnr })
		elseif action.command then
			client:exec_cmd(action, { bufnr = bufnr })
		end
	end
end

local function format_go_buffer(bufnr)
	organize_imports(bufnr)
	vim.lsp.buf.format({
		bufnr = bufnr,
		async = false,
		timeout_ms = 2000,
		filter = function(client)
			return client.name == "gopls"
		end,
	})
end

vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("go-buffer-settings", { clear = true }),
	pattern = { "go", "gomod", "gowork", "gotmpl" },
	callback = function(args)
		vim.bo[args.buf].expandtab = false
		vim.bo[args.buf].shiftwidth = 4
		vim.bo[args.buf].tabstop = 4
	end,
})

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("go-lsp-format-on-save", { clear = true }),
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if not client or client.name ~= "gopls" or not go_filetypes[vim.bo[args.buf].filetype] then
			return
		end

		if client:supports_method("textDocument/formatting") then
			vim.api.nvim_clear_autocmds({ group = format_group, buf = args.buf })
			vim.api.nvim_create_autocmd("BufWritePre", {
				group = format_group,
				buf = args.buf,
				callback = function()
					format_go_buffer(args.buf)
				end,
				desc = "Format Go buffers with gopls before saving",
			})
		end
	end,
})
