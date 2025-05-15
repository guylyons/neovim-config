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
vim.keymap.set("n", "<leader>f", fzf.files, { desc = "Fzf files" })
vim.keymap.set("n", "<leader>k", fzf.blines, { desc = "Fzf lines" })

-- Telescope default keymap
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>p", builtin.find_files, { desc = "Telescope find files" })
vim.keymap.set("n", "<leader>g", builtin.live_grep, { desc = "Telescope live grep" })
vim.keymap.set("n", "<leader>b", builtin.buffers, { desc = "Telescope buffers" })
vim.keymap.set("n", "<leader>h", builtin.help_tags, { desc = "Telescope help tags" })
vim.keymap.set("n", "<leader>v", builtin.registers, { desc = "Telescope help tags" })
