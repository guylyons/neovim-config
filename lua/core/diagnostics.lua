-- The single vim.diagnostic.config() call site.
--
-- tiny-inline-diagnostic renders diagnostics as virtual text itself, so
-- Neovim's own virtual_text stays off; plugins/tiny.lua only sets the plugin
-- up. If that plugin ever fails to load, plugins/init.lua reports it and
-- diagnostics fall back to signs and underline.
--
-- Float borders come from 'winborder' in core/options.lua.
vim.diagnostic.config({
	severity_sort = true,
	update_in_insert = false,
	virtual_text = false,
	float = {
		source = "if_many",
	},
})
