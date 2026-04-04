-- Guy Lyons
-- Custom NeoVim configuration
-- 2025

if vim.loader and vim.loader.enable then
  vim.loader.enable()
end

require("settings")
require("plugins")
require("keybindings")
