-- Guy Lyons
-- Custom NeoVim configuration
-- 2025

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    {
      "marko-cerovac/material.nvim",
      lazy = false, -- Load it immediately
      priority = 1000, -- Load this before other plugins to apply the theme
      config = function()
        require('material').setup({
          contrast = {
            terminal = false, -- Enable contrast for terminal
            sidebars = true, -- Enable contrast for sidebars like NvimTree
            floating_windows = true, -- Enable contrast for floating windows
          },
          styles = {
            comments = { italic = true },
            keywords = { bold = true },
            functions = { bold = true, italic = true },
          },
        })
        vim.cmd("colorscheme material-deep-ocean") -- Set the theme
      end,
    },
    {
      'nvim-telescope/telescope.nvim', tag = '0.1.8',
      dependencies = { 'nvim-lua/plenary.nvim' }
    },
    {
      "nvim-treesitter/nvim-treesitter",
      config = function()
        local parser_config = require "nvim-treesitter.parsers".get_parser_configs()
      end
    },
    {
      "neovim/nvim-lspconfig",
      dependencies = {
        {
          "folke/lazydev.nvim",
          ft = "lua",
          opts = {
            library = {
              -- See the configuration section for more details
              -- Load luvit types when the `vim.uv` word is found
              { path = "${3rd}/luv/library", words = { "vim%.uv" } },
            },
          },
        },
      },
      config = function()
        require('lspconfig').lua_ls.setup {}
      end,
    },
    {
      "williamboman/mason.nvim",
      config = function()
        require("mason").setup()
      end,
    },
    {
      -- Completion Plugins
      'hrsh7th/nvim-cmp',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline',
      -- Snippet Plugins for `vsnip`
      'hrsh7th/cmp-vsnip',
      'hrsh7th/vim-vsnip',
    },
    {
      "NeogitOrg/neogit",
      dependencies = {
        "nvim-lua/plenary.nvim",         -- required
        "sindrets/diffview.nvim",        -- optional - Diff integration

        -- Only one of these is needed.
        "nvim-telescope/telescope.nvim", -- optional
        "ibhagwan/fzf-lua",              -- optional
        "echasnovski/mini.pick",         -- optional
      },
      config = true
    },
    ---@type LazySpec
    {
      "mikavilpas/yazi.nvim",
      event = "VeryLazy",
      keys = {
        -- 👇 in this section, choose your own keymappings!
        {
          "<leader>-",
          mode = { "n", "v" },
          "<cmd>Yazi<cr>",
          desc = "Open yazi at the current file",
        },
        {
          -- Open in the current working directory
          "<leader>cw",
          "<cmd>Yazi cwd<cr>",
          desc = "Open the file manager in nvim's working directory",
        },
        {
          -- NOTE: this requires a version of yazi that includes
          -- https://github.com/sxyazi/yazi/pull/1305 from 2024-07-18
          "<c-up>",
          "<cmd>Yazi toggle<cr>",
          desc = "Resume the last yazi session",
        },
      },
      ---@type YaziConfig
      opts = {
        -- if you want to open yazi instead of netrw, see below for more info
        open_for_directories = false,
        keymaps = {
          show_help = "<f1>",
        },
      },
    }
  },
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "habamax" } },
  -- automatically check for plugin updates
  checker = { enabled = false },
})

-- My keybindings
vim.keymap.set("i", "jj", "<Esc>", { noremap = true, silent = true })
-- Save
vim.keymap.set('n', '<leader><CR>', ':w<CR>', { noremap = true, silent = true })
-- Quit
vim.keymap.set('n', '<leader>;', ':qa<CR>', { noremap = true, silent = true })
-- Lazy Update
vim.keymap.set('n', '<leader>u', ':Lazy update<CR>', { noremap = true, silent = true })
-- Neogit
vim.keymap.set('n', '<leader>m', ':Neogit<CR>', { desc = 'Fzf lines' })
-- Yazi
vim.keymap.set('n', '<leader>j', ':Yazi<CR>', { desc = 'Opens Yazi' })
-- Ex
vim.keymap.set('n', '<leader>e', ':Ex<CR>', { desc = 'Opens Ex' })

-- Clipboard
vim.opt.clipboard = "unnamedplus"

-- General indentation settings
vim.opt.expandtab = true        -- Use spaces instead of tabs
vim.opt.shiftwidth = 2          -- Number of spaces for each indentation level
vim.opt.tabstop = 2             -- Number of spaces for a tab character
vim.opt.smartindent = true      -- Automatically indent new lines
vim.opt.autoindent = true       -- Copy indentation from the previous line

-- Automatically return to the last editing position when reopening a file
vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local line = mark[1]
    local col = mark[2]
    if line > 0 and line <= vim.api.nvim_buf_line_count(0) then
      vim.api.nvim_win_set_cursor(0, { line, col })
    end
  end,
})

-- Search highlight fix
-- turns off keyword highlighting after cursor movement
vim.api.nvim_create_autocmd('CursorMoved', {
  group = vim.api.nvim_create_augroup('auto-hlsearch', { clear = true }),
  callback = function ()
    if vim.v.hlsearch == 1 and vim.fn.searchcount().exact_match == 0 then
      vim.schedule(function () vim.cmd.nohlsearch() end)
    end
  end
})

-- FZF lua
local fzf = require('fzf-lua')
vim.keymap.set('n', '<leader>f', fzf.files, { desc = 'Fzf files' })
vim.keymap.set('n', '<leader>k', fzf.lines, { desc = 'Fzf lines' })

-- Telescope default keymap
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>p', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>g', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>b', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>h', builtin.help_tags, { desc = 'Telescope help tags' })
vim.keymap.set('n', '<leader>v', builtin.registers, { desc = 'Telescope help tags' })

-- Folds with Tree-sitter
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldenable = true  -- Enable folding
vim.opt.foldlevel = 1     -- Expand all folds by default

vim.opt.relativenumber = true -- Show relative line numbers
vim.opt.number = true         -- Show the current line's absolute number

-- Completion setup for `nvim-cmp`
local cmp = require('cmp')

cmp.setup({
  snippet = {
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users
      -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users
      -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'vsnip' }, -- For `vsnip` users
  }, {
    { name = 'buffer' },
  }),
})

-- For `/` and `?` in cmdline
cmp.setup.cmdline({ '/', '?' }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' }
  },
})

-- For `:` in cmdline
-- cmp.setup.cmdline(':', {
--   mapping = cmp.mapping.preset.cmdline(),
--   sources = cmp.config.sources({
--     { name = 'path' }
--   }, {
--     { name = 'cmdline' }
--   }),
-- })

