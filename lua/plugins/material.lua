return {
	"marko-cerovac/material.nvim",
	lazy = false, -- Load it immediately
	priority = 1000, -- Load this before other plugins to apply the theme
	config = function()
		require("material").setup({
			contrast = {
				terminal = false, -- Enable contrast for terminal
				sidebars = true, -- Enable contrast for sidebars like NvimTree
				floating_windows = true, -- Enable contrast for floating windows
			},
			styles = {
				comments = { italic = true },
				keywords = { bold = true },
				functions = { bold = true, italic = true },
			},
		})
		vim.cmd("colorscheme material-deep-ocean") -- Set the theme
	end,
}
