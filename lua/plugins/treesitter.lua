local ok, treesitter = pcall(require, "nvim-treesitter")
if not ok then
	return
end

treesitter.setup()

treesitter.install({
	"bash",
	"css",
	"html",
	"javascript",
	"json",
	"lua",
	"php",
	"phpdoc",
	"python",
	"query",
	"twig",
	"typescript",
	"vim",
	"vimdoc",
	"yaml",
})
