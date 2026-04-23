local function notify_error(message)
	vim.schedule(function()
		vim.notify(message, vim.log.levels.ERROR)
	end)
end

-- Require Neovim 0.12+
if vim.fn.has("nvim-0.12") == 0 then
	notify_error("This config requires Neovim 0.12+ (vim.pack).")
	return
end

-- Optional: simple PackUpdate shim
if vim.fn.exists(":PackUpdate") == 0 then
	vim.api.nvim_create_user_command("PackUpdate", function()
		vim.pack.update()
	end, { desc = "Update plugins managed by vim.pack" })
end

-- Safe module loader
local function load_module(module_name)
	local ok, err = pcall(require, module_name)
	if not ok then
		notify_error(("Failed to load %s: %s"):format(module_name, err))
	end
	return ok
end

-- Load plugins
local plugin_modules = {
	"plugins.material",
	"plugins.lazydev",
	"plugins.cmp",
	"plugins.lspconfig",
	"plugins.mason",
	"plugins.typescript",
	"plugins.conform",
	"plugins.fzf",
	"plugins.gitsigns",
	"plugins.neogit",
	"plugins.whichkey",
	"plugins.alpha",
	"plugins.emmet",
	"plugins.lualine",
	"plugins.tiny",
}

for _, module_name in ipairs(plugin_modules) do
	load_module(module_name)
end
