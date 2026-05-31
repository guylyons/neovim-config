local ok, treesitter = pcall(require, "nvim-treesitter")
if not ok then
	return
end

local parsers = {
	"bash",
	"css",
	"go",
	"gomod",
	"gosum",
	"gowork",
	"gotmpl",
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
}

treesitter.setup()
treesitter.install(parsers)
