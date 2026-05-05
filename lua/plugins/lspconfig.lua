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

local function find_workspace_root(bufnr)
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  if bufname == "" then
    return vim.uv.cwd()
  end

  local start_dir = vim.fs.dirname(bufname)
  local composer = vim.fs.find("composer.json", { upward = true, path = start_dir })[1]
  if composer then
    return vim.fs.dirname(composer)
  end

  local git_dir = vim.fs.find(".git", { upward = true, path = start_dir, type = "directory" })[1]
  if git_dir then
    return vim.fs.dirname(git_dir)
  end

  return vim.uv.cwd()
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.workspace = capabilities.workspace or {}
capabilities.workspace.didChangeWatchedFiles = nil
vim.lsp.config("*", { capabilities = capabilities })

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("user-lsp", { clear = true }),
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, client.id, event.buf, { autotrigger = true })
    end
  end,
})

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
  root_dir = find_workspace_root,
})

vim.lsp.config("yamlls", {
  filetypes = { "yaml" },
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

vim.diagnostic.config({
  severity_sort = true,
  update_in_insert = false,
  virtual_text = {
    source = "if_many",
  },
  float = {
    source = "if_many",
  },
})
