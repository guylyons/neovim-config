require("tiny-inline-diagnostic").setup({
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
