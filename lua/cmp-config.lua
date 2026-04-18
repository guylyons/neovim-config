local ok_cmp, cmp = pcall(require, "cmp")
if not ok_cmp then
	return
end

local function find_project_root(bufnr)
	local bufname = vim.api.nvim_buf_get_name(bufnr)
	if bufname == "" then
		return vim.uv.cwd() or vim.fn.getcwd()
	end

	local start_dir = vim.fs.dirname(bufname)
	local markers = {
		"composer.json",
		"package.json",
		"pnpm-lock.yaml",
		"yarn.lock",
		"bun.lock",
		"go.mod",
		".git",
	}

	local found = vim.fs.find(markers, { upward = true, path = start_dir })[1]
	if found then
		return vim.fs.dirname(found)
	end

	return start_dir
end

local function get_project_buffers()
	local current_buf = vim.api.nvim_get_current_buf()
	local root = find_project_root(current_buf)
	local buffers = {}
	local seen = {}

	local function add_buf(bufnr)
		if seen[bufnr] then
			return
		end

		if not vim.api.nvim_buf_is_valid(bufnr) or not vim.api.nvim_buf_is_loaded(bufnr) then
			return
		end

		if vim.bo[bufnr].buftype ~= "" then
			return
		end

		local name = vim.api.nvim_buf_get_name(bufnr)
		if name == "" then
			return
		end

		if find_project_root(bufnr) ~= root then
			return
		end

		seen[bufnr] = true
		buffers[#buffers + 1] = bufnr
	end

	add_buf(current_buf)

	for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
		add_buf(bufnr)
	end

	return buffers
end

cmp.setup({
	snippet = {
		expand = function(args)
			vim.fn["vsnip#anonymous"](args.body)
		end,
	},
	mapping = cmp.mapping.preset.insert({
		["<C-Space>"] = cmp.mapping.complete(),
		["<C-e>"] = cmp.mapping.abort(),
		["<CR>"] = cmp.mapping.confirm({ select = true }),
	}),
	completion = {
		completeopt = "menu,menuone,noselect",
	},
	preselect = cmp.PreselectMode.None,
	sources = cmp.config.sources({
		{ name = "nvim_lsp" },
		{ name = "path" },
	}, {
		{
			name = "buffer",
			option = {
				get_bufnrs = get_project_buffers,
			},
		},
	}),
	formatting = {
		format = function(entry, item)
			local labels = {
				nvim_lsp = "[LSP]",
				path = "[Path]",
				buffer = "[Buf]",
				cmdline = "[Cmd]",
			}

			item.menu = labels[entry.source.name] or ("[" .. entry.source.name .. "]")
			return item
		end,
	},
})

cmp.setup.cmdline({ "/", "?" }, {
	mapping = cmp.mapping.preset.cmdline(),
	sources = {
		{ name = "buffer" },
	},
})

cmp.setup.cmdline(":", {
	mapping = cmp.mapping.preset.cmdline(),
	sources = cmp.config.sources({
		{ name = "path" },
	}, {
		{ name = "cmdline" },
	}),
})
