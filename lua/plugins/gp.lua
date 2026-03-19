return {
	"robitx/gp.nvim",
	enabled = function()
		return vim.env.OPENAI_API_KEY ~= nil and vim.env.OPENAI_API_KEY ~= ""
	end,
	dependencies = {
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
	},
	keys = {
		{ "<leader>aa", "<Cmd>GpChatNew<CR>", desc = "New AI chat" },
		{ "<leader>ap", "<Cmd>GpPopup<CR>", desc = "AI popup" },
		{ "<leader>at", "<Cmd>GpChatToggle<CR>", desc = "Toggle AI chat" },
		{ "<leader>ar", "<Cmd>GpRewrite<CR>", mode = "v", desc = "Rewrite selection" },
	},
	config = function()
		require("gp").setup({
			providers = {
				openai = {
					secret = os.getenv("OPENAI_API_KEY"),
				},
			},
		})
	end,
}
