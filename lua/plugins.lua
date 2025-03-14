-- plugins.lua

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
      "lewis6991/gitsigns.nvim",
      config = function()
        -- Define the highlights separately
        vim.api.nvim_set_hl(0, 'GitSignsAdd', { link = 'GitGutterAdd' })
        vim.api.nvim_set_hl(0, 'GitSignsChange', { link = 'GitGutterChange' })
        vim.api.nvim_set_hl(0, 'GitSignsDelete', { link = 'GitGutterDelete' })
        vim.api.nvim_set_hl(0, 'GitSignsTopdelete', { link = 'GitGutterDelete' })
        vim.api.nvim_set_hl(0, 'GitSignsChangedelete', { link = 'GitGutterChangeDelete' })

        -- Configure gitsigns
        require('gitsigns').setup {
          signs = {
            add = { text = '▍' },
            change = { text = '▍' },
            delete = { text = '▾' },
            topdelete = { text = '▾' },
            changedelete = { text = '▾' },
          },
          numhl = true, -- Highlight line numbers
          linehl = false, -- Highlight the whole line
          current_line_blame = false, -- Show blame on the current line
          preview_config = { border = 'rounded' }, -- Border style for previews
        }
      end
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
    },
    {
      "pmizio/typescript-tools.nvim",
      dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
      opts = {},
    }
  },
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "habamax" } },
  -- automatically check for plugin updates
  checker = { enabled = false },
})
