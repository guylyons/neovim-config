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
require("core.options") -- leader keys, netrw, folds, numbers, clipboard, indentation
require("core.autocmds") -- auto-clear hlsearch, restore cursor position, treesitter folds
require("core.diagnostics") -- vim.diagnostic.config(); inline text comes from tiny.lua

-- AI-assisted inline edit commands
require("core.codex_edit").setup()
require("core.ai_edit").setup()

-- Plugins and mappings
require("plugins") -- install via vim.pack, then set up each plugin module
require("core.keymaps") -- custom key mappings (loaded last so plugins exist)
