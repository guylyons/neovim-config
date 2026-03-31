-- My keybindings
vim.keymap.set("i", "jj", "<Esc>", { noremap = true, silent = true })
-- Save
vim.keymap.set("n", "<leader>w", ":w<CR>", { noremap = true, silent = true, desc = "Save" })
vim.keymap.set("n", "<leader><CR>", ":w<CR>", { noremap = true, silent = true })
-- Quit
vim.keymap.set("n", "<leader>q", ":q<CR>", { noremap = true, silent = true, desc = "Quit window" })
vim.keymap.set("n", "<leader>Q", ":qa<CR>", { noremap = true, silent = true, desc = "Quit all" })
vim.keymap.set("n", "<leader>;", ":qa<CR>", { noremap = true, silent = true })
-- Open (macOS)
vim.keymap.set("n", "<leader>O", ":!open %:p:h<CR>", { noremap = true, silent = true })
-- Lazy Update
vim.keymap.set("n", "<leader>u", ":Lazy update<CR>", { noremap = true, silent = true })
-- Neogit
vim.keymap.set("n", "<leader>m", ":Neogit<CR>", { desc = "Neogit status" })
-- gp.nvim
vim.keymap.set("n", "<leader>aa", ":GpChatNew<CR>", { noremap = true, silent = true, desc = "New AI chat" })
vim.keymap.set("n", "<leader>at", ":GpChatToggle<CR>", { noremap = true, silent = true, desc = "Toggle AI chat" })
vim.keymap.set("n", "<leader>ap", ":GpPopup<CR>", { noremap = true, silent = true, desc = "AI popup" })
vim.keymap.set("v", "<leader>ar", ":<C-u>GpRewrite<CR>", { noremap = true, silent = true, desc = "Rewrite selection" })
-- Ex
vim.keymap.set("n", "<leader>e", ":Ex ", { desc = "Open Ex and allow entering a path" })
vim.keymap.set("n", "<leader>j", ":e ", { desc = "Open Ex and allow entering a path" })
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
  local git_root = vim.fs.find(".git", { upward = true, type = "directory" })[1]
  if git_root then
    return vim.fs.dirname(git_root)
  end

  return vim.uv.cwd()
end

-- FZF lua
local fzf = require("fzf-lua")
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
vim.keymap.set("n", "<leader>b", fzf.buffers, { desc = "Fzf buffers" })
vim.keymap.set("n", "<leader>k", function()
  fzf.blines({
    fzf_opts = {
      ["--exact"] = "",
    },
  })
end, { desc = "Fzf lines (exact match)" })
vim.keymap.set("n", "<leader>p", function()
  fzf.files({ cwd = get_cwd() })
end, { desc = "Fzf files (current dir)" })
vim.keymap.set("n", "<leader>P", function()
  fzf.files({ cwd = get_root() })
end, { desc = "Fzf files (project root)" })
vim.keymap.set("n", "<leader>r", fzf.oldfiles, { desc = "Fzf recent files" })
vim.keymap.set("n", "<leader>.", fzf.resume, { desc = "Resume last Fzf picker" })
vim.keymap.set("n", "<leader>d", fzf.diagnostics_document, { desc = "Fzf document diagnostics" })
vim.keymap.set("n", "<leader>D", fzf.diagnostics_workspace, { desc = "Fzf workspace diagnostics" })
vim.keymap.set("n", "<leader>s", fzf.git_status, { desc = "Fzf git status" })
vim.keymap.set("n", "<leader>h", fzf.help_tags, { desc = "Fzf help tags" })
vim.keymap.set("n", "<leader>v", fzf.registers, { desc = "Fzf registers" })

-- LSP and diagnostics
vim.keymap.set("n", "gd", fzf.lsp_definitions, { desc = "Go to definition" })
vim.keymap.set("n", "gr", fzf.lsp_references, { desc = "Go to references" })
vim.keymap.set("n", "gi", fzf.lsp_implementations, { desc = "Go to implementations" })
vim.keymap.set("n", "gt", fzf.lsp_typedefs, { desc = "Go to type definitions" })
vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover documentation" })
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename symbol" })
vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
