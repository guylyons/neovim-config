return {
	"lewis6991/gitsigns.nvim",
	config = function()
		-- Define the highlights separately
		vim.api.nvim_set_hl(0, "GitSignsAdd", { link = "GitGutterAdd" })
		vim.api.nvim_set_hl(0, "GitSignsChange", { link = "GitGutterChange" })
		vim.api.nvim_set_hl(0, "GitSignsDelete", { link = "GitGutterDelete" })
		vim.api.nvim_set_hl(0, "GitSignsTopdelete", { link = "GitGutterDelete" })
		vim.api.nvim_set_hl(0, "GitSignsChangedelete", { link = "GitGutterChangeDelete" })

		-- Configure gitsigns
		require("gitsigns").setup({
			signs = {
				add = { text = "▍" },
				change = { text = "▍" },
				delete = { text = "▾" },
				topdelete = { text = "▾" },
				changedelete = { text = "▾" },
			},
			numhl = true, -- Highlight line numbers
			linehl = false, -- Highlight the whole line
			current_line_blame = false, -- Show blame on the current line
			preview_config = { border = "rounded" }, -- Border style for previews
		})
	end,
}
