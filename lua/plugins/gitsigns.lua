vim.pack.add({
  "https://github.com/lewis6991/gitsigns.nvim",
})

local ok, gitsigns = pcall(require, "gitsigns")
if not ok then
  return
end

vim.api.nvim_set_hl(0, "GitSignsAdd", { link = "GitGutterAdd" })
vim.api.nvim_set_hl(0, "GitSignsChange", { link = "GitGutterChange" })
vim.api.nvim_set_hl(0, "GitSignsDelete", { link = "GitGutterDelete" })
vim.api.nvim_set_hl(0, "GitSignsTopdelete", { link = "GitGutterDelete" })
vim.api.nvim_set_hl(0, "GitSignsChangedelete", { link = "GitGutterChangeDelete" })

gitsigns.setup({
  signs = {
    add = { text = "▍" },
    change = { text = "▍" },
    delete = { text = "▾" },
    topdelete = { text = "▾" },
    changedelete = { text = "▾" },
  },
  numhl = true,
  linehl = false,
  current_line_blame = false,
  preview_config = { border = "rounded" },
  on_attach = function(bufnr)
    local map = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
    end

    map("n", "]h", gitsigns.next_hunk, "Next hunk")
    map("n", "[h", gitsigns.prev_hunk, "Previous hunk")
    map("n", "<leader>hp", gitsigns.preview_hunk, "Preview hunk")
    map("n", "<leader>hs", gitsigns.stage_hunk, "Stage hunk")
    map("n", "<leader>hr", gitsigns.reset_hunk, "Reset hunk")
  end,
})
