-- Guy Lyons
-- Custom NeoVim configuration
-- 2026

if vim.loader and vim.loader.enable then
	vim.loader.enable()
end

require("core.options")
require("core.autocmds")
require("core.diagnostics")
require("plugins")
require("core.keymaps")
