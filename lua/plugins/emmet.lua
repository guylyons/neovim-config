return {
	"olrtg/nvim-emmet",
	config = function()
		vim.keymap.set({ "n", "v" }, "<leader>xe", require("nvim-emmet").wrap_with_abbreviation)
		vim.keymap.set("i", "<Tab>", function()
			if require("nvim-emmet").wrap_with_abbreviation() then
				return "<Cmd>lua vim.opt.selecting = false<CR>"
			end
			return "<Tab>"
		end, { expr = true })
	end,
}
