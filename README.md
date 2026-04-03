# Neovim Config

Personal Neovim config built around Neovim `vim.pack`, native Neovim 0.12 LSP, and a small plugin set for PHP/Drupal, JavaScript/TypeScript, and general editing.

## Requirements

- Neovim 0.12+
- Git
- A working `node` and `npm`
- `OPENAI_API_KEY` exported in your shell if you want to use `gp.nvim`
- Optional language servers/formatters installed on your machine

This config uses Neovim's built-in package manager (`vim.pack`) and installs plugins on startup when missing.

## Highlights

- Theme: `material-deep-ocean`
- Plugin manager: `vim.pack`
- Completion: `nvim-cmp` + `vim-vsnip`
- Fuzzy finding: `fzf-lua`
- Git UI: `neogit` + `diffview.nvim` + `gitsigns.nvim`
- AI assistant: `gp.nvim`
- Formatting: `conform.nvim`
- Syntax: `nvim-treesitter`
- Drupal support: `drupal.nvim`
- TypeScript LSP: `typescript-tools.nvim`

## Language Support

### Enabled when installed

The config only enables LSP servers if their executables are available in `PATH`.

- Lua: `lua-language-server`
- Python: `pyright-langserver`
- Bash: `bash-language-server`
- PHP: `phpactor`
- Emmet LSP: `emmet-language-server`
- YAML: `yaml-language-server`
- Drupal: `drupal_ls`

### TypeScript and React

Inline Emmet abbreviation expansion comes from `mattn/emmet-vim`; in HTML-like buffers, typing an abbreviation such as `div.card` and pressing `<Tab>` expands it.

TypeScript support uses `pmizio/typescript-tools.nvim`, not `ts_ls`.

Important details:

- `mason-lspconfig` is configured to exclude `ts_ls` auto-enable to avoid conflicts.
- Neovim prepends Homebrew and the default NVM Node bin path at startup if `node`/`npm` are missing.
- `tsx` is included in Tree-sitter, so `.tsx` highlighting works.

If TypeScript or React stops working, check:

1. `:checkhealth`
2. `:echo exepath('node')`
3. `:echo exepath('npm')`
4. `:LspInfo`

## Formatters

Configured through `conform.nvim`:

- Lua: `stylua`
- Python: `isort`, `black`
- Rust: `rustfmt`
- JavaScript: `prettierd`, fallback `prettier`

## Tree-sitter Parsers

Installed parsers:

- `lua`
- `javascript`
- `typescript`
- `tsx`
- `twig`
- `php`
- `yaml`

## Keymaps

Core mappings from [lua/keybindings.lua](/Users/guy/.config/nvim/lua/keybindings.lua):

- `jj`: leave insert mode
- `<leader>w`: save
- `<leader><CR>`: save
- `<leader>q`: quit current window
- `<leader>Q`: quit all
- `<leader>;`: quit all
- `<leader>O`: open current file directory in Finder
- `<leader>u`: `:lua vim.pack.update()`
- `<leader>m`: open Neogit
- `<leader>aa`: new `gp.nvim` chat
- `<leader>at`: toggle `gp.nvim` chat
- `<leader>ap`: open `gp.nvim` popup
- `<leader>ar`: rewrite selected text with `gp.nvim`
- `<leader>e`: open `:Ex`
- `<leader>j`: open `:Ex`
- `<leader>f`: FZF files (project root)
- `<leader>F`: FZF git files
- `<leader>k`: FZF buffer lines
- `<leader>p`: FZF files (current dir)
- `<leader>P`: FZF files (project root)
- `<leader>r`: FZF recent files
- `<leader>.`: resume last FZF picker
- `<leader>g`: FZF live grep (current dir)
- `<leader>G`: FZF live grep (project root)
- `<leader>b`: FZF buffers
- `<leader>c`: FZF commands
- `<leader>d`: FZF document diagnostics
- `<leader>D`: FZF workspace diagnostics
- `<leader>s`: FZF git status
- `<leader>h`: FZF help tags
- `<leader>v`: FZF registers
- `gd`: FZF definitions
- `gr`: FZF references
- `gi`: FZF implementations
- `gt`: FZF type definitions
- `K`: hover docs
- `<leader>rn`: rename symbol
- `<leader>ca`: code action
- `[d` / `]d`: previous / next diagnostic
- `[h` / `]h`: previous / next git hunk
- `<leader>hp`: preview hunk
- `<leader>hs`: stage hunk
- `<leader>hr`: reset hunk
- `<Tab>`: expand Emmet abbreviations in HTML/CSS/template buffers

## Structure

- [init.lua](/Users/guy/.config/nvim/init.lua): bootstrap and plugin loading
- [lua/plugin_manager.lua](/Users/guy/.config/nvim/lua/plugin_manager.lua): `vim.pack` plugin registration and setup adapter
- [lua/settings.lua](/Users/guy/.config/nvim/lua/settings.lua): editor options, PATH bootstrap, filetype autocommands
- [lua/keybindings.lua](/Users/guy/.config/nvim/lua/keybindings.lua): custom mappings
- [lua/cmp-config.lua](/Users/guy/.config/nvim/lua/cmp-config.lua): completion config
- [lua/plugins](/Users/guy/.config/nvim/lua/plugins): plugin specs consumed by `vim.pack`

## Notes

- This config uses native `vim.lsp.enable()` instead of older `lspconfig.setup()` patterns.
- `:LspInfo`, `:LspRestart`, and `:LspLog` are provided as compatibility commands on top of Neovim 0.12's `:lsp` command.
- Missing external executables are skipped instead of throwing startup errors.
- Drupal file patterns like `*.module`, `*.theme`, and Drupal YAML files are forced to the expected filetypes in [lua/settings.lua](/Users/guy/.config/nvim/lua/settings.lua).
