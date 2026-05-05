# Neovim Config

Personal Neovim config built around Neovim `vim.pack`, native Neovim 0.12 LSP/completion, and a small plugin set for PHP/Drupal, JavaScript/TypeScript, and general editing.

## Requirements

- Neovim 0.12+
- Git
- A working `node` and `npm` for JavaScript/TypeScript tooling
- Optional language servers/formatters installed on your machine

This config uses Neovim's built-in package manager (`vim.pack`) and installs plugins on startup when missing.

## Highlights

- Plugin manager: `vim.pack`
- Completion: native Neovim autocomplete + `vim.lsp.completion`
- Fuzzy finding: `fzf-lua`
- Git signs: `gitsigns.nvim`
- Formatting: `conform.nvim`
- Syntax: `nvim-treesitter`
- Drupal support: filetypes, Drupal import jumping, optional `drupal_ls`
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
- `tsx` is included in Tree-sitter, so `.tsx` highlighting works.

If TypeScript or React stops working, check:

1. `:checkhealth`
2. `:echo exepath('node')`
3. `:echo exepath('npm')`
4. `:checkhealth vim.lsp`

## Formatters

Configured through `conform.nvim`:

- Lua: `stylua`
- Python: `isort`, `black`
- Rust: `rustfmt`
- JavaScript: `prettierd`, fallback `prettier`
- PHP: `pint`, fallback `php_cs_fixer`, fallback `phpcbf`

## Tree-sitter Parsers

Recommended parsers:

- `lua`
- `bash`
- `css`
- `html`
- `javascript`
- `json`
- `typescript`
- `tsx`
- `twig`
- `php`
- `yaml`

Install missing parsers with `:TSInstall <language>` and update them with `:TSUpdate`.

## Keymaps

Core mappings from [lua/keybindings.lua](/Users/guy/.config/nvim/lua/keybindings.lua):

- `jj`: leave insert mode
- `<C-Space>`: trigger LSP completion
- `<leader>w`: next window
- `<leader><CR>`: save
- `<leader>q`: quit current window
- `<leader>Q`: quit all
- `<leader>;`: quit all
- `<leader>O`: open current file directory in Finder
- `<leader>u`: `:lua vim.pack.update()`
- `<leader>j`: open `:Ex`
- `<leader>f`: FZF files (project root)
- `<leader>F`: FZF git files
- `<leader>k`: FZF buffer lines
- `<leader>p`: FZF files (project root)
- `<leader>P`: FZF files (current dir)
- `<leader>r`: FZF recent files
- `<leader>.`: resume last FZF picker
- `<leader>g`: FZF live grep (project root)
- `<leader>b`: FZF buffers
- `<leader>c`: FZF commands
- `<leader>d`: FZF document diagnostics
- `<leader>D`: FZF workspace diagnostics
- `<leader>S`: FZF git status
- `<leader>h`: FZF help tags
- `<leader>v`: FZF registers
- `<leader>s`: Flash jump
- `gd`: go to definition, with Drupal import-path fallback
- `gr`: FZF references
- `gi`: FZF implementations
- `gt`: FZF type definitions
- `K`: hover docs
- `<leader>rn`: rename symbol
- `<leader>a`: code action
- `<leader>lr`: restart LSP
- `<leader>lf`: format buffer
- `[h` / `]h`: previous / next git hunk
- `<leader>Hp`: preview hunk
- `<leader>Hs`: stage hunk
- `<leader>Hr`: reset hunk
- `<Tab>`: expand Emmet abbreviations in HTML/CSS/template buffers

## Structure

- [init.lua](/Users/guy/.config/nvim/init.lua): bootstrap and plugin loading
- [lua/settings.lua](/Users/guy/.config/nvim/lua/settings.lua): editor options, completion options, filetypes, folding
- [lua/keybindings.lua](/Users/guy/.config/nvim/lua/keybindings.lua): custom mappings
- [lua/plugins](/Users/guy/.config/nvim/lua/plugins): plugin setup modules

## Notes

- This config uses native `vim.lsp.enable()` instead of older `lspconfig.setup()` patterns.
- Use `:lsp restart` for restarts and `:checkhealth vim.lsp` for LSP diagnostics.
- Missing external executables are skipped instead of throwing startup errors.
- Drupal file patterns like `*.module`, `*.theme`, and Drupal YAML files are forced to the expected filetypes in [lua/settings.lua](/Users/guy/.config/nvim/lua/settings.lua).
