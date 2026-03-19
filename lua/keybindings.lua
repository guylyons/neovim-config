local map = vim.keymap.set

local function open_current_directory()
	local dir = vim.fn.expand("%:p:h")
	if dir == "" then
		return
	end

	local opener
	if vim.fn.has("macunix") == 1 then
		opener = "open"
	elseif vim.fn.has("unix") == 1 then
		opener = "xdg-open"
	elseif vim.fn.has("win32") == 1 then
		opener = "start"
	end

	if opener then
		vim.fn.jobstart({ opener, dir }, { detach = true })
	end
end

map("i", "jj", "<Esc>", { desc = "Leave insert mode" })
map("n", "<leader><CR>", "<Cmd>write<CR>", { desc = "Save buffer" })
map("n", "<leader>;", "<Cmd>qa<CR>", { desc = "Quit all" })
map("n", "<leader>O", open_current_directory, { desc = "Open current directory" })
map("n", "<leader>u", "<Cmd>Lazy update<CR>", { desc = "Update plugins" })
map("n", "<leader>j", vim.cmd.Ex, { desc = "Open netrw" })
map({ "n", "i", "v", "s", "c" }, "<D-g>", "<Esc><Esc>", { desc = "Clear mode state" })
