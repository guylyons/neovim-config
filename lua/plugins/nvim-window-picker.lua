local picker = require("window-picker")

picker.setup({
  hint = "floating-big-letter",
  selection_chars = "ASDFGHJKL",
  filter_rules = {
    autoselect_one = true,
    include_current_win = true,
    include_unfocusable_windows = false,
    bo = {
      filetype = { "NvimTree", "neo-tree", "notify", "snacks_notif" },
      buftype = { "terminal" },
    },
  },
})
