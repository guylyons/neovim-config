return {
	"robitx/gp.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
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
