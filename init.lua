-- Guy Lyons
-- Personal Neovim 0.12+ configuration repository.
-- Loads editor settings, native vim.pack plugins, keymaps, completion,
-- LSP, formatting, Tree-sitter, and other feature modules from lua/.
-- "Debugging is twice as hard as writing the code in the first place." - Brian Kernighan
-- "Simplicity is prerequisite for reliability." - Dennis Ritchie
-- 2026

if vim.loader and vim.loader.enable then
	vim.loader.enable()
end

require("core.options")
require("core.autocmds")
require("core.diagnostics")
require("core.codex_edit").setup()
require("plugins")
require("core.keymaps")
