-- Guy Lyons's personal Neovim configuration (requires 0.12+).
--
-- Bootstraps editor options and loads feature modules from lua/: native
-- vim.pack plugins, keymaps, completion, LSP, formatting, and Tree-sitter.
--
-- "Debugging is twice as hard as writing the code in the first place." - Brian Kernighan
--
-- "Simplicity is prerequisite for reliability." - Dennis Ritchie

vim.loader.enable()

-- Core editor configuration
require("core.options") -- vim.opt settings: numbers, indentation, search, clipboard
require("core.autocmds") -- event hooks: highlight on yank, trim trailing whitespace
require("core.diagnostics") -- diagnostic display: signs, virtual text, underlines, floats

-- AI-assisted inline edit commands
require("core.codex_edit").setup()
require("core.ai_edit").setup()

-- Plugins and mappings
require("plugins") -- load and configure plugins
require("core.keymaps") -- custom key mappings
