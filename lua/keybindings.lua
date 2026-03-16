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

-- FZF lua
local fzf = require("fzf-lua")
vim.keymap.set("n", "<leader>ff", fzf.files, { desc = "Fzf files" })
vim.keymap.set("n", "<leader>fg", function()
	fzf.live_grep({ cwd = telescope_cwd() })
end, { desc = "Fzf live grep (current dir)" })
vim.keymap.set("n", "<leader>fb", fzf.buffers, { desc = "Fzf buffers" })
vim.keymap.set("n", "<leader>fk", function()
	fzf.blines({
		fzf_opts = {
			["--exact"] = "",
		},
	})
end, { desc = "Fzf lines (exact match)" })

-- Telescope default keymap
local builtin = require("telescope.builtin")
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

vim.keymap.set("n", "<leader>p", function()
	builtin.find_files({ cwd = telescope_cwd() })
end, { desc = "Telescope find files (current dir)" })
vim.keymap.set("n", "<leader>P", function()
	builtin.find_files({ cwd = telescope_root() })
end, { desc = "Telescope find files (project root)" })
vim.keymap.set("n", "<leader>g", function()
	builtin.live_grep({ cwd = telescope_cwd() })
end, { desc = "Telescope live grep (current dir)" })
vim.keymap.set("n", "<leader>G", function()
	builtin.live_grep({ cwd = telescope_root() })
end, { desc = "Telescope live grep (project root)" })
vim.keymap.set("n", "<leader>b", function()
	builtin.buffers({
		sort_lastused = true,
		sort_mru = true,
	})
end, { desc = "Telescope buffers (last used first)" })
vim.keymap.set("n", "<leader>h", builtin.help_tags, { desc = "Telescope help tags" })
vim.keymap.set("n", "<leader>v", builtin.registers, { desc = "Telescope help tags" })
