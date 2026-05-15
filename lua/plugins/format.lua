local function format_buffer()
	vim.lsp.buf.format({ async = true })
end

-- Formatting is intentionally manual. Avoid format-on-save so unrelated
-- indentation/formatting churn does not create noisy diffs.
vim.api.nvim_create_user_command("Format", format_buffer, {
	desc = "Format the current buffer with an attached LSP client",
})

vim.keymap.set({ "n", "v" }, "<leader>lf", format_buffer, {
	desc = "Format buffer",
})
