-- Renders diagnostics as inline virtual text. Neovim's own virtual_text is
-- turned off in core/diagnostics.lua so the two do not draw over each other.
require("tiny-inline-diagnostic").setup({
	preset = "modern",
	options = {
		show_source = {
			enabled = true,
			if_many = true,
		},
	},
})
