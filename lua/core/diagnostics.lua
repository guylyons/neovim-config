-- Baseline diagnostic display. plugins/tiny.lua replaces virtual_text with
-- tiny-inline-diagnostic when that plugin loads; the setting below is the
-- fallback for when it does not.
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
