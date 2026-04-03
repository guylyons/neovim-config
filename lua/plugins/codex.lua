return {
  "rhart92/codex.nvim",
  config = function()
    require("codex").setup({})
  end,
  keys = {
    {
      "<leader>ct",
      function()
        require("codex").toggle()
      end,
      desc = "Codex toggle",
    },
    {
      "<leader>cb",
      function()
        require("codex").send_buffer()
      end,
      desc = "Codex send buffer",
    },
    {
      "<leader>cs",
      function()
        require("codex").send_selection()
      end,
      mode = "v",
      desc = "Codex send selection",
    },
  },
}
