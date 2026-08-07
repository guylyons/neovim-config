local ok, gitsigns = pcall(require, "gitsigns")
if not ok then
	return
end

gitsigns.setup({
	signs = {
		add = { text = "▍" },
		change = { text = "▍" },
		delete = { text = "▾" },
		topdelete = { text = "▾" },
		changedelete = { text = "▾" },
	},
	numhl = true,
	linehl = false,
	current_line_blame = false,
	preview_config = { border = "rounded" },
	on_attach = function(bufnr)
		local map = function(lhs, rhs, desc)
			vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = desc })
		end

		map("]h", function()
			gitsigns.nav_hunk("next")
		end, "Next hunk")
		map("[h", function()
			gitsigns.nav_hunk("prev")
		end, "Previous hunk")
		map("<leader>Hp", gitsigns.preview_hunk, "Preview hunk")
		map("<leader>Hs", gitsigns.stage_hunk, "Stage hunk")
		map("<leader>Hr", gitsigns.reset_hunk, "Reset hunk")
	end,
})
