return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	config = function()
		require("nvim-treesitter.configs").setup({
			ensure_installed = { "tsx", "typescript", "javascript", "twig", "blade", "html", "css" },
			highlight = { enable = true },
			indent = { enable = true },
		})
	end,
}
