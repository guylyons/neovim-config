-- Debug helper for inspecting PHP indentation state in the current buffer.
vim.api.nvim_create_user_command("PhpIndentInfo", function()
	local lines = {
		("filetype=%s"):format(vim.bo.filetype),
		("indentexpr=%s"):format(vim.bo.indentexpr ~= "" and vim.bo.indentexpr or "[empty]"),
		("indentkeys=%s"):format(vim.bo.indentkeys ~= "" and vim.bo.indentkeys or "[empty]"),
		("autoindent=%s"):format(vim.bo.autoindent),
		("smartindent=%s"):format(vim.bo.smartindent),
		("cindent=%s"):format(vim.bo.cindent),
	}

	vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO)
end, {
	desc = "Show PHP indentation settings for the current buffer",
})
