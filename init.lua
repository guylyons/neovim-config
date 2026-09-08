-- Guy Lyons
--
-- Personal Neovim 0.12+ configuration repository.
-- Loads editor settings, native vim.pack plugins, keymaps, completion,
-- LSP, formatting, Tree-sitter, and other feature modules from lua/.
--
-- "Debugging is twice as hard as writing the code in the first place." - Brian Kernighan
--
-- "Simplicity is prerequisite for reliability." - Dennis Ritchie

vim.loader.enable()

require("core.options") -- editor behavior: line numbers, indentation, search, clipboard, and other vim.opt settings
require("core.autocmds") -- event-driven hooks that run automatically (e.g. highlight on yank, trim whitespace on save)
require("core.diagnostics") -- how LSP errors/warnings appear: signs, virtual text, underlines, and float windows

-- AI-assisted inline edit commands
require("core.codex_edit").setup()
require("core.ai_edit").setup()

require("plugins") -- load and configure all plugins
require("core.keymaps") -- register custom key mappings
