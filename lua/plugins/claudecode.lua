-- Claude Code IDE integration. snacks.nvim is not installed, so the terminal
-- uses the native provider. <leader>a is code action, so Claude lives under <leader>C.
require("claudecode").setup({
	terminal = { provider = "native" },
})

local map = vim.keymap.set
map("n", "<leader>Cc", "<cmd>ClaudeCode<cr>", { desc = "Toggle Claude" })
map("n", "<leader>Cf", "<cmd>ClaudeCodeFocus<cr>", { desc = "Focus Claude" })
map("n", "<leader>Cr", "<cmd>ClaudeCode --resume<cr>", { desc = "Resume Claude" })
map("n", "<leader>CC", "<cmd>ClaudeCode --continue<cr>", { desc = "Continue Claude" })
map("n", "<leader>Cm", "<cmd>ClaudeCodeSelectModel<cr>", { desc = "Select Claude model" })
map("n", "<leader>Cb", "<cmd>ClaudeCodeAdd %<cr>", { desc = "Add current buffer" })
map("v", "<leader>Cs", "<cmd>ClaudeCodeSend<cr>", { desc = "Send to Claude" })
map("n", "<leader>Ca", "<cmd>ClaudeCodeDiffAccept<cr>", { desc = "Accept diff" })
map("n", "<leader>Cd", "<cmd>ClaudeCodeDiffDeny<cr>", { desc = "Deny diff" })
