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

local function find_workspace_root(bufnr)
	local bufname = vim.api.nvim_buf_get_name(bufnr)
	if bufname == "" then
		return vim.uv.cwd()
	end

	local start_dir = vim.fs.dirname(bufname)
	local composer = vim.fs.find("composer.json", { upward = true, path = start_dir })[1]
	if composer then
		return vim.fs.dirname(composer)
	end

	local git_dir = vim.fs.find(".git", { upward = true, path = start_dir, type = "directory" })[1]
	if git_dir then
		return vim.fs.dirname(git_dir)
	end

	return vim.uv.cwd()
end

local function sanitize_text(value)
	local text = tostring(value)
	text = text:gsub("[\r\n]+", " ")
	text = text:gsub("%s+", " ")
	return vim.trim(text)
end

local function format_list(values)
	if type(values) ~= "table" or vim.tbl_isempty(values) then
		return "none"
	end

	local items = {}
	for _, value in ipairs(values) do
		items[#items + 1] = sanitize_text(value)
	end

	return table.concat(items, ", ")
end

local function format_command(cmd)
	if type(cmd) == "function" then
		return "<function>"
	end

	if type(cmd) == "table" then
		local parts = {}
		local keys = {}
		for key, value in pairs(cmd) do
			if type(key) == "number" and value ~= nil then
				keys[#keys + 1] = key
			end
		end
		table.sort(keys)
		for _, key in ipairs(keys) do
			parts[#parts + 1] = sanitize_text(cmd[key])
		end
		return table.concat(parts, " ")
	end

	return sanitize_text(cmd)
end

local function show_lsp_info()
	local bufnr = vim.api.nvim_get_current_buf()
	local bufname = vim.api.nvim_buf_get_name(bufnr)
	local filename = bufname ~= "" and vim.fn.fnamemodify(bufname, ":~:.") or "[No Name]"
	local filetype = vim.bo[bufnr].filetype
	local clients = vim.lsp.get_clients({ bufnr = bufnr })
	local configs = vim.lsp.get_configs()
	local sorted_configs = {}
	local lines = {
		"LSP Info",
		"",
		("Buffer: %s"):format(sanitize_text(filename)),
		("Filetype: %s"):format(sanitize_text(filetype ~= "" and filetype or "[none]")),
		("Working dir: %s"):format(sanitize_text(vim.uv.cwd() or "[unknown]")),
		"",
		("Attached clients (%d):"):format(#clients),
	}

	if #clients == 0 then
		lines[#lines + 1] = "  - none"
	else
		for _, client in ipairs(clients) do
			lines[#lines + 1] = ("  - %s (id=%d, root=%s)"):format(
				sanitize_text(client.name),
				client.id,
				sanitize_text(client.root_dir or "[none]")
			)
			if client.server_capabilities and client.server_capabilities.documentSymbolProvider then
				lines[#lines + 1] = "    document symbols: yes"
			end
		end
	end

	for _, config in ipairs(configs) do
		sorted_configs[#sorted_configs + 1] = config
	end
	table.sort(sorted_configs, function(a, b)
		return sanitize_text(a.name) < sanitize_text(b.name)
	end)

	lines[#lines + 1] = ""
	lines[#lines + 1] = ("Configured servers (%d):"):format(#sorted_configs)
	if #sorted_configs == 0 then
		lines[#lines + 1] = "  - none"
	else
		for _, config in ipairs(sorted_configs) do
			lines[#lines + 1] = ("  - %s"):format(sanitize_text(config.name or "[unnamed]"))
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

	for i, line in ipairs(lines) do
		lines[i] = sanitize_text(line)
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
capabilities.workspace = capabilities.workspace or {}
capabilities.workspace.didChangeWatchedFiles = nil
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
	root_dir = find_workspace_root,
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
