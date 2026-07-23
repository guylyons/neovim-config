-- Tree-sitter (nvim-treesitter `main` branch).
--
-- Highlighting and folds are started per-buffer in lua/core/autocmds.lua via
-- vim.treesitter.start(); this module only ensures the parsers those features
-- need are compiled and installed.
--
-- The `main` branch compiles parsers with the external `tree-sitter` CLI. When
-- that CLI is missing (for example on a fresh machine) we skip installation
-- entirely so startup never errors -- buffers simply fall back to regex syntax
-- and indent folds until `tree-sitter` is available. Install it once with:
--   brew install tree-sitter-cli
local ok, ts = pcall(require, "nvim-treesitter")
if not ok then
	return
end

-- Parsers to keep installed. Anything not in the plugin's available set is
-- ignored, so listing an unknown name here is harmless.
local ensure = {
	"bash",
	"css",
	"diff",
	"gitcommit",
	"html",
	"javascript",
	"json",
	"lua",
	"luadoc",
	"markdown",
	"markdown_inline",
	"php",
	"phpdoc",
	"python",
	"query",
	"scss",
	"tsx",
	"twig",
	"typescript",
	"vim",
	"vimdoc",
	"yaml",
}

-- Parsers can only be compiled when the tree-sitter CLI is on PATH.
if vim.fn.executable("tree-sitter") == 0 then
	return
end

local installed = {}
for _, parser in ipairs(ts.get_installed("parsers")) do
	installed[parser] = true
end

local available = {}
for _, parser in ipairs(ts.get_available()) do
	available[parser] = true
end

local missing = {}
for _, parser in ipairs(ensure) do
	if available[parser] and not installed[parser] then
		missing[#missing + 1] = parser
	end
end

-- install() is asynchronous and a no-op once parsers are present, so this only
-- does work on first launch or when a new parser is added to `ensure`.
if #missing > 0 then
	ts.install(missing)
end

-- Keep installed parsers current with the pinned plugin revision. Runs after
-- a plugin update rather than on every startup.
vim.api.nvim_create_autocmd("User", {
	pattern = "PackChanged",
	group = vim.api.nvim_create_augroup("treesitter-update", { clear = true }),
	callback = function(event)
		local data = event.data
		if type(data) == "table" and data.spec and data.spec.name == "nvim-treesitter" and data.kind == "update" then
			pcall(function()
				ts.update()
			end)
		end
	end,
})
