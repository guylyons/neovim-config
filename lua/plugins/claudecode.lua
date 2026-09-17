-- Claude Code IDE integration. snacks.nvim is not installed, so the terminal
-- uses the native provider. <leader>a is code action, so Claude lives under <leader>C.

-- The native provider only does left/right vsplits, so wrap it and move its
-- window to a full-width split at the bottom after it opens.
local native = require("claudecode.terminal.native")
local height_percentage = 0.4

local function move_to_bottom()
	local bufnr = native.get_active_bufnr()
	if not bufnr then
		return
	end
	for _, win in ipairs(vim.fn.win_findbuf(bufnr)) do
		if vim.api.nvim_win_get_width(win) < vim.o.columns then
			vim.api.nvim_win_call(win, function()
				vim.cmd("wincmd J")
			end)
			vim.api.nvim_win_set_height(win, math.floor(vim.o.lines * height_percentage))
		end
	end
end

local bottom = setmetatable({}, { __index = native })
for _, name in ipairs({ "open", "simple_toggle", "focus_toggle", "toggle" }) do
	bottom[name] = function(...)
		local result = native[name](...)
		move_to_bottom()
		return result
	end
end

require("claudecode").setup({
	terminal = { provider = bottom },
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
