vim.pack.add({
  "https://github.com/rhart92/codex.nvim",
})

local ok, codex = pcall(require, "codex")
if not ok then
  return
end

codex.setup({})

vim.keymap.set("n", "<leader>ct", codex.toggle, { desc = "Codex toggle" })
vim.keymap.set("n", "<leader>cb", codex.send_buffer, { desc = "Codex send buffer" })
vim.keymap.set("v", "<leader>cs", codex.send_selection, { desc = "Codex send selection" })
