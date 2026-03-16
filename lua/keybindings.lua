-- My keybindings
vim.keymap.set("i", "jj", "<Esc>", { noremap = true, silent = true })
-- Save
vim.keymap.set("n", "<leader><CR>", ":w<CR>", { noremap = true, silent = true })
-- Quit
vim.keymap.set("n", "<leader>;", ":qa<CR>", { noremap = true, silent = true })
-- Open (macOS)
vim.keymap.set("n", "<leader>O", ":!open %:p:h<CR>", { noremap = true, silent = true })
-- Lazy Update
vim.keymap.set("n", "<leader>u", ":Lazy update<CR>", { noremap = true, silent = true })
-- Neogit
vim.keymap.set("n", "<leader>m", ":Neogit<CR>", { desc = "Fzf lines" })
-- Ex
vim.keymap.set("n", "<leader>j", ":Ex<CR>", { desc = "Opens Ex" })
vim.keymap.set({ "n", "i", "v", "s", "c" }, "<D-g>", "<Esc><Esc>", { noremap = true, silent = true })

local function telescope_cwd()
	if vim.bo.filetype == "netrw" and vim.b.netrw_curdir then
		return vim.b.netrw_curdir
	end

	local bufname = vim.api.nvim_buf_get_name(0)
	if bufname ~= "" then
		return vim.fn.fnamemodify(bufname, ":h")
	end

	return vim.uv.cwd()
end

local function telescope_root()
	local git_root = vim.fs.find(".git", { upward = true, type = "directory" })[1]
	if git_root then
		return vim.fs.dirname(git_root)
	end

	return vim.uv.cwd()
end

-- FZF lua
local fzf = require("fzf-lua")
vim.keymap.set("n", "<leader>f", fzf.files, { desc = "Fzf files" })
vim.keymap.set("n", "<leader>g", function()
	fzf.live_grep({ cwd = telescope_cwd() })
end, { desc = "Fzf live grep (current dir)" })
vim.keymap.set("n", "<leader>G", function()
	fzf.live_grep({ cwd = telescope_root() })
end, { desc = "Fzf live grep (project root)" })
vim.keymap.set("n", "<leader>b", fzf.buffers, { desc = "Fzf buffers" })
vim.keymap.set("n", "<leader>k", function()
	fzf.blines({
		fzf_opts = {
			["--exact"] = "",
		},
	})
end, { desc = "Fzf lines (exact match)" })
vim.keymap.set("n", "<leader>p", function()
	fzf.files({ cwd = telescope_cwd() })
end, { desc = "Fzf files (current dir)" })
vim.keymap.set("n", "<leader>P", function()
	fzf.files({ cwd = telescope_root() })
end, { desc = "Fzf files (project root)" })
vim.keymap.set("n", "<leader>h", fzf.help_tags, { desc = "Fzf help tags" })
vim.keymap.set("n", "<leader>v", fzf.registers, { desc = "Fzf registers" })
