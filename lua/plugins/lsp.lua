local function executable(command)
	return vim.fn.executable(command) == 1
end

-- Neovim deep-merges this over vim.lsp.protocol.make_client_capabilities(), so
-- only the deltas belong here. cmp_nvim_lsp.default_capabilities() takes an
-- options table, not a capabilities table -- do not feed it the defaults.
local ok_cmp_lsp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
local capabilities = ok_cmp_lsp and cmp_lsp.default_capabilities() or {}

-- Opt out of server-driven file watching; it is expensive on large trees.
-- The merge cannot delete keys, so disable it rather than setting it to nil.
capabilities.workspace = vim.tbl_deep_extend("force", capabilities.workspace or {}, {
	didChangeWatchedFiles = { dynamicRegistration = false },
})

vim.lsp.config("*", {
	capabilities = capabilities,
})

vim.lsp.config("intelephense", {
	filetypes = { "php" },
	root_markers = { "composer.json", ".git" },
})

-- lspconfig ships no runtime library for lua_ls, so out of the box it knows
-- nothing about the Neovim API -- hovering vim.api.nvim_create_autocmd reports
-- "unknown". Point it at $VIMRUNTIME so editing this config gets real
-- completion, signatures and type checking.
--
-- A project that ships its own .luarc.json has already said how it wants to be
-- analysed, so leave it alone. This config directory is the exception: it is
-- Neovim Lua whether or not it grows a .luarc.json.
local function wants_nvim_runtime(client)
	local folders = client.workspace_folders
	if not folders or not folders[1] then
		return true
	end

	local root = folders[1].name
	if root == vim.fn.stdpath("config") then
		return true
	end

	return not (vim.uv.fs_stat(root .. "/.luarc.json") or vim.uv.fs_stat(root .. "/.luarc.jsonc"))
end

vim.lsp.config("lua_ls", {
	on_init = function(client)
		if not wants_nvim_runtime(client) then
			return
		end

		client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua or {}, {
			runtime = {
				version = "LuaJIT",
				-- Resolve require() the way Neovim does; see :h lua-module-load.
				path = { "lua/?.lua", "lua/?/init.lua" },
			},
			workspace = {
				-- $VIMRUNTIME only. Pulling in the whole 'runtimepath' indexes
				-- every installed plugin and makes lua_ls crawl on this repo.
				library = { vim.env.VIMRUNTIME },
			},
		})
	end,
	settings = {
		Lua = {
			-- Redundant once the runtime library loads, but it keeps the
			-- undefined-global warning quiet during the initial index.
			diagnostics = { globals = { "vim" } },
			workspace = { checkThirdParty = false },
			telemetry = { enable = false },
		},
	},
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
		"css",
		"eruby",
		"html",
		"less",
		"sass",
		"scss",
		"twig",
	},
})

if executable("drupal_ls") then
	vim.lsp.config("drupal_ls", {
		cmd = { "drupal_ls" },
		filetypes = { "php", "twig", "yaml" },
		root_markers = { "composer.json", ".git" },
	})
	vim.lsp.enable("drupal_ls")
end

-- Only enable a server when its binary is on PATH, so a missing tool stays
-- silent instead of erroring on every matching buffer.
local servers = {
	bashls = { "bash-language-server" },
	cssls = { "vscode-css-language-server" },
	emmet_language_server = { "emmet-language-server" },
	gopls = { "gopls" },
	html = { "vscode-html-language-server" },
	intelephense = { "intelephense" },
	jsonls = { "vscode-json-language-server" },
	lua_ls = { "lua-language-server", "lua_ls" },
	pyright = { "pyright-langserver" },
	yamlls = { "yaml-language-server" },
}

for server, commands in pairs(servers) do
	if vim.iter(commands):any(executable) then
		vim.lsp.enable(server)
	end
end

-- nvim-lspconfig no longer ships these commands; keep the familiar names.
local function compat_command(name, desc, callback)
	if vim.fn.exists(":" .. name) == 0 then
		vim.api.nvim_create_user_command(name, callback, { desc = desc })
	end
end

compat_command("LspInfo", "Show LSP health", function()
	vim.cmd.checkhealth("vim.lsp")
end)

compat_command("LspRestart", "Restart LSP clients", function()
	vim.cmd("lsp restart")
end)

compat_command("LspLog", "Show LSP log", function()
	vim.cmd.edit(vim.fn.fnameescape(vim.lsp.log.get_filename()))
end)
