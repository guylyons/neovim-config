local ok, tiny = pcall(require, "tiny-inline-diagnostic")
if not ok then
	return
end

tiny.setup({
	add_messages = {
		display_count = true,
	},
	multilines = {
		enabled = true,
		always_show = true,
	},
	show_source = {
		enabled = true,
	},
})
