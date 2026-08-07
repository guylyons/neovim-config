local which_key = require("which-key")

which_key.setup({
	preset = "modern",
})

vim.keymap.set("n", "<leader>?", function()
	which_key.show({ global = false })
end, { desc = "Buffer keymaps" })
