vim.pack.add({
  "https://github.com/folke/which-key.nvim",
})

local ok, which_key = pcall(require, "which-key")
if not ok then
  return
end

which_key.setup({})
vim.keymap.set("n", "<leader>?", function()
  which_key.show({ global = false })
end, { desc = "Buffer Local Keymaps (which-key)" })
