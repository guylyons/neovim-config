local function enable_when_available(server_name, commands)
	local command_list = type(commands) == "table" and commands or { commands }
	for _, command in ipairs(command_list) do
		if vim.fn.executable(command) == 1 then
			vim.lsp.enable(server_name)
			return true
		end
	end
	return false
end

local function create_lsp_compat_command(name, callback, desc)
	if vim.fn.exists(":" .. name) == 0 then
		vim.api.nvim_create_user_command(name, callback, { desc = desc })
	end
end

local function format_list(values)
	if type(values) ~= "table" or vim.tbl_isempty(values) then
		return "none"
	end

	local items = {}
	for _, value in ipairs(values) do
		items[#items + 1] = tostring(value)
	end

	return table.concat(items, ", ")
end

local function format_command(cmd)
	if type(cmd) == "table" then
		return table.concat(cmd, " ")
	end

	return tostring(cmd)
end

local function show_lsp_info()
	local bufnr = vim.api.nvim_get_current_buf()
	local bufname = vim.api.nvim_buf_get_name(bufnr)
	local filename = bufname ~= "" and vim.fn.fnamemodify(bufname, ":~:.") or "[No Name]"
	local filetype = vim.bo[bufnr].filetype
	local clients = vim.lsp.get_clients({ bufnr = bufnr })
	local configs = vim.lsp.get_configs()
	local lines = {
		"LSP Info",
		"",
		("Buffer: %s"):format(filename),
		("Filetype: %s"):format(filetype ~= "" and filetype or "[none]"),
		("Working dir: %s"):format(vim.uv.cwd() or "[unknown]"),
		"",
		("Attached clients (%d):"):format(#clients),
	}

	if #clients == 0 then
		lines[#lines + 1] = "  - none"
	else
		for _, client in ipairs(clients) do
			lines[#lines + 1] = ("  - %s (id=%d, root=%s)"):format(client.name, client.id, client.root_dir or "[none]")
			if client.server_capabilities and client.server_capabilities.documentSymbolProvider then
				lines[#lines + 1] = "    document symbols: yes"
			end
		end
	end

	local config_names = vim.tbl_keys(configs)
	table.sort(config_names)
	lines[#lines + 1] = ""
	lines[#lines + 1] = ("Configured servers (%d):"):format(#config_names)
	if #config_names == 0 then
		lines[#lines + 1] = "  - none"
	else
		for _, name in ipairs(config_names) do
			local config = configs[name]
			lines[#lines + 1] = ("  - %s"):format(name)
			if config.filetypes then
				lines[#lines + 1] = ("    filetypes: %s"):format(format_list(config.filetypes))
			end
			if config.cmd then
				lines[#lines + 1] = ("    cmd: %s"):format(format_command(config.cmd))
			end
			if config.root_markers then
				lines[#lines + 1] = ("    root markers: %s"):format(format_list(config.root_markers))
			end
		end
	end

	vim.cmd("botright new")
	local info_buf = vim.api.nvim_get_current_buf()
	vim.bo[info_buf].buftype = "nofile"
	vim.bo[info_buf].bufhidden = "wipe"
	vim.bo[info_buf].swapfile = false
	vim.bo[info_buf].buflisted = false
	vim.bo[info_buf].modifiable = true
	vim.bo[info_buf].filetype = "markdown"
	vim.api.nvim_buf_set_lines(info_buf, 0, -1, false, lines)
	vim.bo[info_buf].modifiable = false
	vim.keymap.set("n", "q", "<cmd>close<cr>", {
		buffer = info_buf,
		silent = true,
		desc = "Close LSP info",
	})
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
local ok_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if ok_cmp then
	capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
end
vim.lsp.config("*", { capabilities = capabilities })

vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			diagnostics = { globals = { "vim" } },
			workspace = { checkThirdParty = false },
			telemetry = { enable = false },
		},
	},
})

vim.lsp.config("phpactor", {
	filetypes = { "php" },
	root_markers = { "composer.json", ".git" },
})

vim.lsp.config("yamlls", {
	settings = {
		yaml = {
			keyOrdering = false,
		},
	},
})

vim.lsp.config("emmet_language_server", {
	filetypes = {
		"astro",
		"css",
		"eruby",
		"html",
		"javascriptreact",
		"less",
		"php",
		"sass",
		"scss",
		"svelte",
		"twig",
		"typescriptreact",
		"vue",
	},
})

if vim.fn.executable("drupal_ls") == 1 then
	vim.lsp.config("drupal_ls", {
		cmd = { "drupal_ls" },
		filetypes = { "php", "twig", "yaml" },
		root_markers = { "composer.json", ".git" },
	})
	vim.lsp.enable("drupal_ls")
end

enable_when_available("lua_ls", { "lua-language-server", "lua_ls" })
enable_when_available("pyright", "pyright-langserver")
enable_when_available("bashls", "bash-language-server")
enable_when_available("phpactor", "phpactor")
enable_when_available("emmet_language_server", "emmet-language-server")
enable_when_available("yamlls", "yaml-language-server")

create_lsp_compat_command("LspInfo", show_lsp_info, "Show LSP info")

create_lsp_compat_command("LspRestart", function()
	vim.cmd("lsp restart")
end, "Restart LSP clients")

create_lsp_compat_command("LspLog", function()
	local log_path = vim.fs.joinpath(vim.fn.stdpath("state"), "lsp.log")
	vim.cmd("edit " .. vim.fn.fnameescape(log_path))
end, "Show LSP log")

vim.diagnostic.config({
	severity_sort = true,
	update_in_insert = false,
	virtual_text = {
		source = "if_many",
	},
	float = {
		border = "rounded",
		source = "if_many",
	},
})
