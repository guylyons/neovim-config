-- My keybindings
vim.keymap.set("i", "jj", "<Esc>", { noremap = true, silent = true })

local ok_undotree, undotree = pcall(function()
	vim.cmd.packadd("nvim.undotree")
	return require("undotree")
end)

if ok_undotree then
	vim.keymap.set("n", "<leader>t", undotree.open, { desc = "Open undo tree" })
end
-- Save
vim.keymap.set("n", "<leader><CR>", ":w<CR>", { noremap = true, silent = true })
-- Window switching
vim.keymap.set("n", "<leader>w", "<C-w>p", { noremap = true, silent = true, desc = "Toggle previous window" })
-- Quit
vim.keymap.set("n", "<leader>q", ":q<CR>", { noremap = true, silent = true, desc = "Quit window" })
vim.keymap.set("n", "<leader>Q", ":qa<CR>", { noremap = true, silent = true, desc = "Quit all" })
vim.keymap.set("n", "<leader>;", ":qa<CR>", { noremap = true, silent = true })
-- Open (macOS)
vim.keymap.set("n", "<leader>O", function()
	local path = vim.fn.expand("%:p:h")
	if path == "" then
		path = vim.uv.cwd() or "."
	end

	vim.ui.open(path)
end, { noremap = true, silent = true, desc = "Open containing folder" })
-- Plugin update
vim.keymap.set("n", "<leader>u", function()
	vim.pack.update()
end, { noremap = true, silent = true, desc = "Update plugins" })
-- Neogit
vim.keymap.set("n", "<leader>m", ":Neogit<CR>", { desc = "Neogit status" })
-- e
vim.keymap.set("n", "<leader>j", ":Ex ", { desc = "Open Ex and allow entering a path" })
vim.keymap.set({ "n", "i", "v", "s", "c" }, "<D-g>", "<Esc><Esc>", { noremap = true, silent = true })

local function get_cwd()
	if vim.bo.filetype == "netrw" and vim.b.netrw_curdir then
		return vim.b.netrw_curdir
	end

	local bufname = vim.api.nvim_buf_get_name(0)
	if bufname ~= "" then
		return vim.fn.fnamemodify(bufname, ":h")
	end

	return vim.uv.cwd()
end

local function get_root()
	local start_path = get_cwd() or vim.uv.cwd()
	local git_root = vim.fs.find(".git", {
		path = start_path,
		upward = true,
		type = "directory",
	})[1]
	if git_root then
		return vim.fs.dirname(git_root)
	end

	return start_path
end

local function open_path_if_exists(path)
	if not path or path == "" or vim.uv.fs_stat(path) == nil then
		return false
	end

	vim.cmd.edit(vim.fn.fnameescape(path))
	return true
end

local function jump_to_drupal_import_definition()
	if vim.bo.filetype ~= "php" then
		return false
	end

	local line = vim.api.nvim_get_current_line()
	local namespace = line:match("^%s*use%s+([^;]+);")
	if not namespace then
		return false
	end

	namespace = namespace:gsub("%s+as%s+.+$", "")
	if not namespace:match("^Drupal\\") then
		return false
	end

	local tail = namespace:match("^Drupal\\(.+)$")
	if not tail or tail == "" then
		return false
	end

	local root = get_root()
	local candidates = {
		vim.fs.joinpath(root, "docroot", "core", "lib", "Drupal", tail:gsub("\\", "/") .. ".php"),
	}

	local parts = vim.split(tail, "\\", { plain = true, trimempty = true })
	if #parts >= 2 then
		local module = parts[1]
		local remainder = table.concat(parts, "/", 2)
		candidates[#candidates + 1] =
			vim.fs.joinpath(root, "docroot", "core", "modules", module, "src", remainder .. ".php")
		candidates[#candidates + 1] =
			vim.fs.joinpath(root, "docroot", "modules", "custom", module, "src", remainder .. ".php")
		candidates[#candidates + 1] =
			vim.fs.joinpath(root, "docroot", "modules", "contrib", module, "src", remainder .. ".php")
		candidates[#candidates + 1] = vim.fs.joinpath(root, "docroot", "modules", module, "src", remainder .. ".php")
	end

	for _, path in ipairs(candidates) do
		if open_path_if_exists(path) then
			return true
		end
	end

	return false
end

vim.keymap.set("n", "gd", function()
	if jump_to_drupal_import_definition() then
		return
	end

	vim.lsp.buf.definition({ reuse_win = true })
end, { desc = "Go to definition" })

-- FZF lua
local ok_fzf, fzf = pcall(require, "fzf-lua")
if ok_fzf then
	vim.keymap.set("n", "<leader>f", function()
		fzf.files({ cwd = get_root() })
	end, { desc = "Fzf files (project root)" })

	vim.keymap.set("n", "<leader>F", fzf.git_files, { desc = "Fzf git files" })
	vim.keymap.set("n", "<leader>c", fzf.commands, { desc = "Fzf commands" })
	vim.keymap.set("n", "<leader>g", function()
		fzf.live_grep({ cwd = get_cwd() })
	end, { desc = "Fzf live grep (current dir)" })

	vim.keymap.set("n", "<leader>G", function()
		fzf.live_grep({ cwd = get_root() })
	end, { desc = "Fzf live grep (project root)" })

	local function grep_word_under_cursor()
		fzf.grep_cword({ cwd = get_root() })
	end

	vim.keymap.set("n", "<leader>*", grep_word_under_cursor, { desc = "Fzf grep word under cursor (project root)" })

	vim.keymap.set("n", "<leader>b", fzf.buffers, { desc = "Fzf buffers" })

	vim.keymap.set("n", "<leader>k", function()
		fzf.blines({
			fzf_opts = {
				["--exact"] = "",
			},
		})
	end, { desc = "Fzf lines (exact match)" })

	vim.keymap.set("n", "<leader>P", function()
		fzf.files({ cwd = get_cwd() })
	end, { desc = "Fzf files (current dir)" })

	vim.keymap.set("n", "<leader>p", function()
		fzf.files({ cwd = get_root() })
	end, { desc = "Fzf files (project root)" })

	vim.keymap.set("n", "<leader>r", fzf.oldfiles, { desc = "Fzf recent files" })
	vim.keymap.set("n", "<leader>.", fzf.resume, { desc = "Resume last Fzf picker" })
	vim.keymap.set("n", "<leader>d", fzf.diagnostics_document, { desc = "Fzf document diagnostics" })
	vim.keymap.set("n", "<leader>D", fzf.diagnostics_workspace, { desc = "Fzf workspace diagnostics" })
	vim.keymap.set("n", "<leader>s", fzf.git_status, { desc = "Fzf git status" })
	vim.keymap.set("n", "<leader>h", fzf.help_tags, { desc = "Fzf help tags" })
	vim.keymap.set("n", "<leader>v", fzf.registers, { desc = "Fzf registers" })

	-- LSP picker bindings
	vim.keymap.set("n", "gr", fzf.lsp_references, { desc = "Go to references" })
	vim.keymap.set("n", "gi", fzf.lsp_implementations, { desc = "Go to implementations" })
	vim.keymap.set("n", "gt", fzf.lsp_typedefs, { desc = "Go to type definitions" })
	vim.keymap.set("n", "<leader>ls", fzf.lsp_document_symbols, { desc = "LSP document symbols" })
	vim.keymap.set("n", "<leader>lS", fzf.lsp_workspace_symbols, { desc = "LSP workspace symbols" })
end

-- LSP and diagnostics
vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover documentation" })
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename symbol" })
vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
vim.keymap.set("n", "<leader>li", ":LspInfo<CR>", { desc = "LSP info" })
vim.keymap.set({ "n", "v" }, "<leader>lf", function()
	require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = "Format buffer" })
