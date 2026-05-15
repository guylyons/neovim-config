local ok, tiny = pcall(require, "tiny-inline-diagnostic")
if not ok then
	return
end

tiny.setup({
	preset = "modern",
	options = {
		show_source = {
			enabled = true,
			if_many = true,
		},
	},
})

vim.diagnostic.config({
	virtual_text = false,
})
