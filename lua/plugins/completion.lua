vim.opt.autocomplete = true
vim.opt.complete = { "o", ".^10", "w^5", "b^5", "u^5" }
vim.opt.completeopt = { "menu", "menuone", "noselect", "popup", "fuzzy" }
vim.opt.pumheight = 12

local completion_group = vim.api.nvim_create_augroup("native-lsp-completion", { clear = true })
local completion_method = vim.lsp.protocol.Methods.textDocument_completion

local function has_lsp_completion()
  return #vim.lsp.get_clients({
    bufnr = 0,
    method = completion_method,
  }) > 0
end

local function trigger_completion()
  if has_lsp_completion() then
    vim.lsp.completion.get()
    return
  end

  vim.api.nvim_feedkeys(vim.keycode("<C-n>"), "i", false)
end

vim.keymap.set("i", "<C-Space>", trigger_completion, { desc = "Trigger completion" })
vim.keymap.set("i", "<C-@>", trigger_completion, { desc = "Trigger completion" })

vim.api.nvim_create_autocmd("LspAttach", {
  group = completion_group,
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)

    if not client or not client:supports_method(completion_method) then
      return
    end

    vim.lsp.completion.enable(true, client.id, event.buf, {
      autotrigger = true,
    })
  end,
})
