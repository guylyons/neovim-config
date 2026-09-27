-- fff: frecency-ranked fuzzy file finder and live grep with a Rust core.
-- Read lazily by the plugin, so a plain table is all the setup it needs.
-- Keymaps live in core/keymaps.lua next to the fzf ones (they share get_root).
vim.g.fff = {
	-- Index on first open, not at startup: launching nvim from $HOME would
	-- otherwise crawl the whole home directory in the background.
	lazy_sync = true,
}
