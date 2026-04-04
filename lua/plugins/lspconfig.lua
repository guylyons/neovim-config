vim.pack.add({
  "https://github.com/neovim/nvim-lspconfig",
})

local function enable_when_available(server_name, commands)
  local command_list = type(commands) == "table" and commands or { commands }
  for _, command in ipairs(command_list) do
    if vim.fn.executable(command) == 1 then
      vim.lsp.enable(server_name)
      return true
    end
  end
  return false
end

local function create_lsp_compat_command(name, callback, desc)
  if vim.fn.exists(":" .. name) == 0 then
    vim.api.nvim_create_user_command(name, callback, { desc = desc })
  end
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
local ok_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if ok_cmp then
  capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
end
vim.lsp.config("*", { capabilities = capabilities })

vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      diagnostics = { globals = { "vim" } },
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
    },
  },
})

vim.lsp.config("phpactor", {
  filetypes = { "php" },
  root_markers = { "composer.json", ".git" },
})

vim.lsp.config("yamlls", {
  settings = {
    yaml = {
      keyOrdering = false,
    },
  },
})

vim.lsp.config("emmet_language_server", {
  filetypes = {
    "astro",
    "css",
    "eruby",
    "html",
    "javascriptreact",
    "less",
    "php",
    "sass",
    "scss",
    "svelte",
    "twig",
    "typescriptreact",
    "vue",
  },
})

if vim.fn.executable("drupal_ls") == 1 then
  vim.lsp.config("drupal_ls", {
    cmd = { "drupal_ls" },
    filetypes = { "php", "twig", "yaml" },
    root_markers = { "composer.json", ".git" },
  })
  vim.lsp.enable("drupal_ls")
end

enable_when_available("lua_ls", { "lua-language-server", "lua_ls" })
enable_when_available("pyright", "pyright-langserver")
enable_when_available("bashls", "bash-language-server")
enable_when_available("phpactor", "phpactor")
enable_when_available("emmet_language_server", "emmet-language-server")
enable_when_available("yamlls", "yaml-language-server")

create_lsp_compat_command("LspInfo", function()
  vim.cmd("checkhealth vim.lsp")
end, "Show LSP info")

create_lsp_compat_command("LspRestart", function()
  vim.cmd("lsp restart")
end, "Restart LSP clients")

create_lsp_compat_command("LspLog", function()
  local log_path = vim.fs.joinpath(vim.fn.stdpath("state"), "lsp.log")
  vim.cmd("edit " .. vim.fn.fnameescape(log_path))
end, "Show LSP log")

vim.diagnostic.config({
  severity_sort = true,
  update_in_insert = false,
  virtual_text = {
    source = "if_many",
  },
  float = {
    border = "rounded",
    source = "if_many",
  },
})
