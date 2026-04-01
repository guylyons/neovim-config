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
				"lua",
				"javascript",
				"javascriptreact",
				"typescript",
				"typescriptreact",
				"tsx",
				"twig",
				"php",
				"yaml",
			},
			callback = function(args)
				pcall(vim.treesitter.start, args.buf)
			end,
		})

		vim.api.nvim_create_autocmd("FileType", {
			group = vim.api.nvim_create_augroup("treesitter-indent", { clear = true }),
			pattern = {
				"lua",
				"javascript",
				"javascriptreact",
				"typescript",
				"typescriptreact",
				"tsx",
				"php",
			},
			callback = function(args)
				vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
			end,
		})
	end,
}
