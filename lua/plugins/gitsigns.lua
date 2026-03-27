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
			on_attach = function(bufnr)
				local gs = package.loaded.gitsigns
				local map = function(mode, lhs, rhs, desc)
					vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
				end

				map("n", "]h", gs.next_hunk, "Next hunk")
				map("n", "[h", gs.prev_hunk, "Previous hunk")
				map("n", "<leader>hp", gs.preview_hunk, "Preview hunk")
				map("n", "<leader>hs", gs.stage_hunk, "Stage hunk")
				map("n", "<leader>hr", gs.reset_hunk, "Reset hunk")
			end,
		})
	end,
}
