-- File tree sidebar. netrw stays the directory browser (`-` in keymaps.lua),
-- so neo-tree must not hijack it.
require("neo-tree").setup({
	close_if_last_window = true,
	filesystem = {
		hijack_netrw_behavior = "disabled",
		follow_current_file = { enabled = true },
		use_libuv_file_watcher = true,
	},
})

vim.keymap.set("n", "<leader>n", "<cmd>Neotree toggle reveal<cr>", { desc = "Toggle file tree" })
