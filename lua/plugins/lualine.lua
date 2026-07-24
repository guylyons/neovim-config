local ok, lualine = pcall(require, "lualine")
if not ok then
	return
end

lualine.setup({
	options = {
		-- material.nvim ships its own palette-matched theme (reads the live
		-- deep-ocean palette). Use it instead of lualine's generic "material",
		-- whose static colors clash with material-deep-ocean.
		theme = "material-nvim",
		icons_enabled = true,
		globalstatus = true,
		component_separators = { left = "", right = "" },
		section_separators = { left = "", right = "" },
	},
	sections = {
		lualine_a = { "mode" },
		lualine_b = {
			"branch",
			{
				"diff",
				-- Source diff counts from gitsigns so they stay consistent with the signs.
				source = function()
					local gs = vim.b.gitsigns_status_dict
					if gs then
						return { added = gs.added, modified = gs.changed, removed = gs.removed }
					end
				end,
			},
		},
		lualine_c = {
			{ "filename", path = 1, symbols = { modified = " ●", readonly = " ", unnamed = "[No Name]" } },
		},
		lualine_x = {
			{ "diagnostics", sources = { "nvim_diagnostic" } },
			"filetype",
		},
		lualine_y = { "encoding", "fileformat" },
		lualine_z = { "progress", "location" },
	},
})
