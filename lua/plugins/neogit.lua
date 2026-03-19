return {
	"NeogitOrg/neogit",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"sindrets/diffview.nvim",
		"ibhagwan/fzf-lua",
	},
	keys = {
		{ "<leader>m", "<Cmd>Neogit<CR>", desc = "Neogit" },
	},
	config = true,
}
