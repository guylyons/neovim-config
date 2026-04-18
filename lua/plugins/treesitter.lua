local ok, treesitter = pcall(require, "nvim-treesitter")
if not ok then
	return
end

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

vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("treesitter-indent", { clear = true }),
	pattern = {
		"html",
		"javascript",
		"javascriptreact",
		"json",
		"jsonc",
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
		vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
		vim.bo[args.buf].smartindent = false
	end,
})
