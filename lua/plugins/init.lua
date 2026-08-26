vim.pack.add({
	"https://github.com/NeogitOrg/neogit",
	"https://github.com/yannvanhalewyn/jujutsu.nvim",
	"https://github.com/L3MON4D3/LuaSnip",
	"https://github.com/lewis6991/gitsigns.nvim",
	"https://github.com/hrsh7th/cmp-buffer",
	"https://github.com/hrsh7th/cmp-nvim-lsp",
	"https://github.com/hrsh7th/cmp-path",
	"https://github.com/hrsh7th/nvim-cmp",
	"https://github.com/nvim-lua/plenary.nvim",
	"https://github.com/saadparwaiz1/cmp_luasnip",
	"https://github.com/folke/flash.nvim",
	"https://github.com/folke/which-key.nvim",
	"https://github.com/goolord/alpha-nvim",
	"https://github.com/ibhagwan/fzf-lua",
	"https://github.com/marko-cerovac/material.nvim",
	"https://github.com/nvim-lualine/lualine.nvim",
	"https://github.com/mattn/emmet-vim",
	"https://github.com/neovim/nvim-lspconfig",
	"https://github.com/nvim-tree/nvim-web-devicons",
	"https://github.com/s1n7ax/nvim-window-picker",
	"https://github.com/sindrets/diffview.nvim",
	"https://github.com/williamboman/mason-lspconfig.nvim",
	"https://github.com/williamboman/mason.nvim",
	"https://github.com/rachartier/tiny-inline-diagnostic.nvim",
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
})

-- Loaded in order: colorscheme before statusline, LSP before language modules.
local plugin_modules = {
	"plugins.treesitter",
	"plugins.alpha",
	"plugins.emmet",
	"plugins.flash",
	"plugins.format",
	"plugins.fzf",
	"plugins.gitsigns",
	"plugins.go",
	"plugins.mason",
	"plugins.material",
	"plugins.lualine",
	"plugins.jujutsu",
	"plugins.neogit",
	"plugins.nvim-window-picker",
	"plugins.lsp",
	"plugins.typescript",
	"plugins.whichkey",
	"plugins.tiny",
}

-- Each module is isolated: one failing plugin reports itself and the rest still
-- load, so the modules themselves do not need their own pcall guards.
local function load_module(module_name)
	local ok, err = pcall(require, module_name)
	if not ok then
		-- Lua appends the whole package.path to "module not found"; keep line one.
		local reason = tostring(err):match("^[^\n]*") or "unknown error"
		vim.schedule(function()
			vim.notify(("Failed to load %s: %s"):format(module_name, reason), vim.log.levels.ERROR)
		end)
	end
end

for _, module_name in ipairs(plugin_modules) do
	load_module(module_name)
end

-- nvim-cmp and LuaSnip are only needed once you start typing, so keep them off the
-- startup path and load them on the first insert. cmp activates from the first
-- typed character (it drives completion off TextChangedI), so nothing is missed.
-- LSP capabilities do not depend on this -- lsp.lua pulls in cmp_nvim_lsp on its
-- own, which is separate from and much cheaper than loading nvim-cmp itself.
vim.api.nvim_create_autocmd("InsertEnter", {
	once = true,
	group = vim.api.nvim_create_augroup("defer-completion", { clear = true }),
	callback = function()
		load_module("plugins.completion")
	end,
})
