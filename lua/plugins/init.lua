local function notify_error(message)
  vim.schedule(function()
    vim.notify(message, vim.log.levels.ERROR)
  end)
end

if vim.fn.has("nvim-0.12") == 0 then
  notify_error("This config requires Neovim 0.12+ (vim.pack).")
  return
end

vim.api.nvim_create_autocmd("PackChanged", {
  group = vim.api.nvim_create_augroup("nvim-pack-hooks", { clear = true }),
  callback = function(ev)
    local data = ev.data or {}
    local spec = data.spec or {}

    if spec.name == "nvim-treesitter" and (data.kind == "install" or data.kind == "update") then
      if not data.active then
        vim.cmd.packadd("nvim-treesitter")
      end
      vim.cmd("TSUpdate")
    end
  end,
})

if vim.fn.exists(":PackUpdate") == 0 then
  vim.api.nvim_create_user_command("PackUpdate", function()
    vim.pack.update()
  end, { desc = "Update plugins managed by vim.pack" })
end

local plugin_modules = {
  "plugins.plenary",
  "plugins.devicons",
  "plugins.diffview",
  "plugins.material",
  "plugins.treesitter",
  "plugins.lazydev",
  "plugins.lspconfig",
  "plugins.mason",
  "plugins.typescript",
  "plugins.conform",
  "plugins.cmp",
  "plugins.fzf",
  "plugins.gitsigns",
  "plugins.neogit",
  "plugins.whichkey",
  "plugins.alpha",
  "plugins.drupal",
  "plugins.emmet",
  "plugins.codex",
  "plugins.lualine",
  "plugins.tiny",
}

for _, module_name in ipairs(plugin_modules) do
  local ok, err = pcall(require, module_name)
  if not ok then
    notify_error(string.format("Failed to load %s: %s", module_name, err))
  end
end
