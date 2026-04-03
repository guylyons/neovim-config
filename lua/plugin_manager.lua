local M = {}

local plugin_modules = {
  "plugins.material",
  "plugins.treesitter",
  "plugins.cmp",
  "plugins.lspconfig",
  "plugins.mason",
  "plugins.typescript",
  "plugins.conform",
  "plugins.gitsigns",
  "plugins.fzf",
  "plugins.neogit",
  "plugins.whichkey",
  "plugins.barbar",
  "plugins.alpha",
  "plugins.drupal",
  "plugins.emmet",
  "plugins.gp",
  "plugins.codex",
  "plugins.lualine",
  "plugins.tiny",
}

local function is_plugin_spec(value)
  if type(value) ~= "table" then
    return false
  end

  if type(value.src) == "string" then
    return true
  end

  if type(value[1]) ~= "string" then
    return false
  end

  local keys = {
    "name",
    "version",
    "branch",
    "tag",
    "commit",
    "dependencies",
    "init",
    "opts",
    "config",
    "keys",
    "ft",
    "event",
    "lazy",
    "priority",
    "build",
  }

  for _, key in ipairs(keys) do
    if value[key] ~= nil then
      return true
    end
  end

  return #value == 1
end

local function flatten_specs(value, out)
  if value == nil then
    return out
  end

  if type(value) == "string" then
    table.insert(out, value)
    return out
  end

  if type(value) ~= "table" then
    return out
  end

  if is_plugin_spec(value) then
    table.insert(out, value)
    return out
  end

  for _, item in ipairs(value) do
    flatten_specs(item, out)
  end

  return out
end

local function normalize_src(src)
  if not src or src == "" then
    return src
  end

  if src:find("://", 1, true) or src:match("^git@") then
    return src
  end

  if src:match("^[%w%._%-]+/[%w%._%-]+$") then
    return "https://github.com/" .. src
  end

  return src
end

local function infer_name_from_src(src)
  if not src or src == "" then
    return ""
  end

  local clean = src:gsub("/+$", ""):gsub("%.git$", "")
  return clean:match("/([^/]+)$") or clean
end

local function infer_module_name(spec, src)
  local name = spec.name or infer_name_from_src(src)
  return name:gsub("%.nvim$", ""):gsub("%.vim$", "")
end

local function notify_error(message)
  vim.schedule(function()
    vim.notify(message, vim.log.levels.ERROR)
  end)
end

local function prefer_core_opt_module(module_name, plugin_dirname)
  local core_opt_path = string.format("%s/site/pack/core/opt/%s", vim.fn.stdpath("data"), plugin_dirname)
  if vim.fn.isdirectory(core_opt_path) == 0 then
    return
  end

  -- Ensure runtime module lookup prefers vim.pack's core/opt copy over stale start dirs.
  vim.opt.rtp:prepend(core_opt_path)

  local loaded = package.loaded[module_name]
  if type(loaded) ~= "table" or type(loaded.setup) ~= "function" then
    return
  end

  local info = debug.getinfo(loaded.setup, "S")
  local source = info and info.source or ""
  if source:sub(1, 1) == "@" then
    source = source:sub(2)
  end

  if not source:find("/site/pack/core/opt/" .. plugin_dirname, 1, true) then
    package.loaded[module_name] = nil
  end
end

local function apply_key_specs(spec)
  if type(spec.keys) ~= "table" then
    return
  end

  for _, key_spec in ipairs(spec.keys) do
    if type(key_spec) == "table" then
      local lhs = key_spec[1]
      local rhs = key_spec[2]
      if lhs and rhs then
        local mode = key_spec.mode or "n"
        local opts = {
          desc = key_spec.desc,
          silent = key_spec.silent,
          expr = key_spec.expr,
          nowait = key_spec.nowait,
          buffer = key_spec.buffer,
          noremap = key_spec.remap ~= true,
        }
        vim.keymap.set(mode, lhs, rhs, opts)
      end
    end
  end
end

function M.setup()
  if vim.fn.has("nvim-0.12") == 0 then
    notify_error("This config requires Neovim 0.12+ (vim.pack).")
    return
  end

  local raw_specs = {}
  for _, module_name in ipairs(plugin_modules) do
    local ok, module_value = pcall(require, module_name)
    if ok then
      flatten_specs(module_value, raw_specs)
    else
      notify_error(string.format("Failed to load %s: %s", module_name, module_value))
    end
  end

  local pack_specs = {}
  local setup_hooks = {}
  local init_hooks = {}
  local seen = {}

  local function register(spec)
    local src
    local pack_spec

    if type(spec) == "string" then
      src = normalize_src(spec)
      pack_spec = { src = src }
    elseif type(spec) == "table" then
      src = normalize_src(spec.src or spec[1])
      pack_spec = { src = src }

      local version = spec.version or spec.branch or spec.tag or spec.commit
      if version then
        pack_spec.version = version
      end
      if spec.name then
        pack_spec.name = spec.name
      end

      if type(spec.dependencies) == "table" then
        for _, dep in ipairs(spec.dependencies) do
          register(dep)
        end
      end

      if type(spec.init) == "function" then
        table.insert(init_hooks, spec.init)
      end
      table.insert(setup_hooks, { spec = spec, src = src })
    else
      return
    end

    if not src or src == "" then
      return
    end

    local key = pack_spec.name or infer_name_from_src(src)
    if not seen[key] then
      seen[key] = true
      table.insert(pack_specs, pack_spec)
    end

  end

  for _, spec in ipairs(raw_specs) do
    register(spec)
  end

  for _, init in ipairs(init_hooks) do
    local ok, err = pcall(init)
    if not ok then
      notify_error("Plugin init hook failed: " .. err)
    end
  end

  vim.pack.add(pack_specs, { confirm = false, load = true })

  prefer_core_opt_module("nvim-web-devicons", "nvim-web-devicons")

  if vim.fn.exists(":PackUpdate") == 0 then
    vim.api.nvim_create_user_command("PackUpdate", function()
      vim.pack.update()
    end, { desc = "Update plugins managed by vim.pack" })
  end

  for _, item in ipairs(setup_hooks) do
    local spec = item.spec
    if type(spec) == "table" then
      apply_key_specs(spec)

      if type(spec.config) == "function" then
        local ok, err = pcall(spec.config)
        if not ok then
          notify_error("Plugin config hook failed: " .. err)
        end
      elseif spec.config == true or spec.opts ~= nil then
        local module_name = infer_module_name(spec, item.src)
        local ok, plugin = pcall(require, module_name)
        if ok and type(plugin.setup) == "function" then
          local ok_setup, err_setup = pcall(plugin.setup, spec.opts or {})
          if not ok_setup then
            notify_error(string.format("Plugin setup failed for %s: %s", module_name, err_setup))
          end
        end
      end
    end
  end
end

return M
