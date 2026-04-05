local ok, typescript_tools = pcall(require, "typescript-tools")
if not ok then
	return
end

typescript_tools.setup({
	settings = {
		separate_diagnostic_server = true,
		publish_diagnostic_on = "insert_leave",
		expose_as_code_action = {
			"add_missing_imports",
			"remove_unused",
			"organize_imports",
		},
		tsserver_max_memory = "auto",
	},
})
