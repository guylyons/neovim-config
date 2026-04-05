local ok, which_key = pcall(require, "which-key")
if not ok then
	return
end

which_key.setup({
	preset = "modern", -- better defaults
})

vim.keymap.set("n", "<leader>?", function()
	which_key.show({ global = false })
end, { desc = "Buffer keymaps" })
