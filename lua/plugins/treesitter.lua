return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	lazy = false,
	build = ":TSUpdate",
	config = function()
		local treesitter = require("nvim-treesitter")

		treesitter.setup({})

		vim.api.nvim_create_autocmd("FileType", {
			group = vim.api.nvim_create_augroup("treesitter-highlight", { clear = true }),
			pattern = {
				"bash",
				"css",
				"html",
				"javascript",
				"javascriptreact",
				"json",
				"jsonc",
				"lua",
				"markdown",
				"markdown_inline",
				"php",
				"scss",
				"tsx",
				"twig",
				"typescript",
				"typescriptreact",
				"yaml",
			},
			callback = function(args)
				pcall(vim.treesitter.start, args.buf)
			end,
		})
	end,
}
