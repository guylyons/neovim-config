vim.pack.add({
  "https://github.com/stevearc/conform.nvim",
})

local ok, conform = pcall(require, "conform")
if not ok then
  return
end

local prettier = { "prettierd", "prettier", stop_after_first = true }
local php_formatters = { "pint", "php_cs_fixer", "phpcbf", stop_after_first = true }

conform.setup({
  notify_on_error = false,
  format_on_save = function(bufnr)
    if vim.b[bufnr].disable_autoformat then
      return
    end
    return {
      timeout_ms = 1500,
      lsp_format = "fallback",
    }
  end,
  formatters_by_ft = {
    lua = { "stylua" },
    python = { "isort", "black" },
    rust = { "rustfmt" },
    javascript = prettier,
    javascriptreact = prettier,
    typescript = prettier,
    typescriptreact = prettier,
    json = prettier,
    jsonc = prettier,
    css = prettier,
    scss = prettier,
    less = prettier,
    html = prettier,
    twig = prettier,
    yaml = prettier,
    yml = prettier,
    markdown = prettier,
    php = php_formatters,
  },
})
