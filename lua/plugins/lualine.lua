local ok, lualine = pcall(require, "lualine")
if not ok then
	return
end

local theme = "material-nvim"
local theme_ok, material_theme = pcall(require, "lualine.themes.material-nvim")
if theme_ok then
	theme = vim.deepcopy(material_theme)
	for _, palette in pairs(theme) do
		if type(palette) == "table" and palette.a then
			palette.a.fg = "#000000"
		end
	end
end

lualine.setup({
	options = {
		-- material.nvim ships its own palette-matched theme (reads the live
		-- deep-ocean palette). Use it instead of lualine's generic "material",
		-- whose static colors clash with material-deep-ocean.
		theme = theme,
		icons_enabled = true,
		globalstatus = true,
		component_separators = { left = "", right = "" },
		section_separators = { left = "", right = "" },
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
