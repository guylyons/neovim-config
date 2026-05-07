vim.diagnostic.config({
	severity_sort = true,
	update_in_insert = false,
	virtual_text = {
		source = "if_many",
	},
	float = {
		border = "rounded",
		source = "if_many",
	},
})
