local function notify_error(message)
	vim.schedule(function()
		vim.notify(message, vim.log.levels.ERROR)
	end)
end

if vim.fn.has("nvim-0.12") == 0 then
	notify_error("This config requires Neovim 0.12+ (vim.pack).")
	return
end

local pack_hooks = vim.api.nvim_create_augroup("nvim-pack-hooks", { clear = true })

local treesitter_parsers = {
	"bash",
	"css",
	"html",
	"javascript",
	"json",
	"lua",
	"markdown",
	"php",
	"scss",
	"tsx",
	"typescript",
	"yaml",
}

vim.api.nvim_create_autocmd("PackChanged", {
	group = pack_hooks,
	callback = function(ev)
		local data = ev.data or {}
		local spec = data.spec or {}

		if spec.name == "nvim-treesitter" and (data.kind == "install" or data.kind == "update") then
			if not data.active then
				vim.cmd.packadd("nvim-treesitter")
			end

			local install_ok = pcall(function()
				require("nvim-treesitter").install(treesitter_parsers, { summary = true }):wait(300000)
			end)
			if not install_ok then
				notify_error("TSInstall failed after nvim-treesitter install/update")
			end

			local ok = pcall(vim.cmd, "TSUpdate")
			if not ok then
				notify_error("TSUpdate failed after nvim-treesitter install/update")
			end
		end
	end,
})

if vim.fn.exists(":PackUpdate") == 0 then
	vim.api.nvim_create_user_command("PackUpdate", function()
		vim.pack.update()
	end, { desc = "Update plugins managed by vim.pack" })
end

local function load_module(module_name)
	local ok, err = pcall(require, module_name)
	if not ok then
		notify_error(("Failed to load %s: %s"):format(module_name, err))
	end
	return ok
end

local plugin_modules = {
	"plugins.material",
	"plugins.lazydev",
	"plugins.cmp",
	"plugins.lspconfig",
	"plugins.mason",
	"plugins.typescript",
	"plugins.treesitter",
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
