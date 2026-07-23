# Neovim Config

Personal Neovim config for Neovim 0.12+, built around `vim.pack`, native LSP configuration, Tree-sitter, and a compact plugin set for PHP/Drupal, JavaScript/TypeScript, Twig, YAML, and general editing.

## Requirements

- Neovim 0.12+
- Git
- A C compiler (Xcode Command Line Tools on macOS) plus `tar` and `curl` to build Tree-sitter parsers
- `tree-sitter` CLI 0.26.1+ for installing Tree-sitter parsers (`brew install tree-sitter-cli`, **not** the npm package)
- `rg` for fast grep integration
- `node` and `npm` for JavaScript/TypeScript, Emmet, YAML, and several language servers
- `go` for Go development tools such as `gopls`
- Optional language servers installed locally or through Mason

## Highlights

- Plugin manager: native `vim.pack`
- LSP: native `vim.lsp.config()` and `vim.lsp.enable()`
- Syntax and folds: `nvim-treesitter` on the `main` branch
- Completion: `nvim-cmp` with LuaSnip, LSP, path, and buffer sources
- Fuzzy finding: `fzf-lua`
- Git UI: `neogit`, `jujutsu.nvim`, `diffview.nvim`, and `gitsigns.nvim`
- Theme: `material-deep-ocean`
- Navigation helpers: `flash.nvim`, `which-key.nvim`, and `nvim-window-picker`

## Language Support

LSP servers are enabled only when their executable is available on `PATH`.

- Lua: `lua-language-server` or `lua_ls`
- PHP: `intelephense`
- Drupal: `drupal_ls`
- Python: `pyright-langserver`
- Bash: `bash-language-server`
- YAML: `yaml-language-server`
- Emmet: `emmet-language-server`
- Go: `gopls`
- TypeScript/JavaScript: `typescript-tools.nvim`

TypeScript support intentionally uses `pmizio/typescript-tools.nvim` rather than `ts_ls`. Mason is configured with `automatic_enable = false`, so native LSP enablement remains explicit in [lua/plugins/lsp.lua](lua/plugins/lsp.lua).

## Formatting

Formatting is intentionally manual to avoid noisy save-time diffs, except Go buffers, which format and organize imports on save through `gopls`.

- `:Format`: format the current buffer through an attached LSP client

## Tree-sitter

Uses `nvim-treesitter` on the `main` branch. Parsers are installed through the
current `main` API in [lua/plugins/treesitter.lua](lua/plugins/treesitter.lua),
which compiles any missing parser from the list below on startup. Installation
requires the external `tree-sitter` CLI (see Requirements); when it is absent,
the config still loads and buffers fall back to regex syntax and indent folds.

Installed parsers include:

- `bash`
- `css`
- `diff`
- `gitcommit`
- `html`
- `javascript`
- `json`
- `lua`
- `luadoc`
- `markdown`
- `markdown_inline`
- `php`
- `phpdoc`
- `python`
- `query`
- `scss`
- `tsx`
- `twig`
- `typescript`
- `vim`
- `vimdoc`
- `yaml`

Folds are enabled through native `vim.treesitter.foldexpr()` in [lua/core/autocmds.lua](lua/core/autocmds.lua), with an indent fallback when Tree-sitter cannot start.

## Keymaps

Core mappings live in [lua/core/keymaps.lua](lua/core/keymaps.lua).

- `jj`: leave insert mode
- `<leader><CR>`: write buffer
- `<leader>q`: quit current window
- `<leader>Q` / `<leader>;`: quit all
- `<leader>O`: open containing folder
- `<leader>u`: run `vim.pack.update()`
- `<leader>m`: open Neogit
- `<leader>J`: open Jujutsu log
- `<leader>w`: pick a window
- `<leader>s`: Flash jump
- `S`: Flash Tree-sitter jump
- `gd`: go to definition, with a Drupal import shortcut for PHP `use Drupal\...` lines
- `gr`, `gi`, `gt`: LSP references, implementations, and type definitions through `fzf-lua`
- `K`: hover documentation
- `<leader>rn`: rename symbol
- `<leader>a`: code action
- `<leader>li`: LSP health
- `<leader>lf`: fzf-lua health
- `:Format`: format the current buffer through an attached LSP client

FZF mappings include project files, git files, live grep, buffer lines, diagnostics, symbols, registers, help tags, and recent files.

## Structure

- [init.lua](init.lua): startup and module loading
- [lua/core/options.lua](lua/core/options.lua): editor options
- [lua/core/autocmds.lua](lua/core/autocmds.lua): search, cursor restore, and folding autocommands
- [lua/core/diagnostics.lua](lua/core/diagnostics.lua): diagnostic display settings
- [lua/core/keymaps.lua](lua/core/keymaps.lua): keymaps and navigation helpers
- [lua/plugins/init.lua](lua/plugins/init.lua): `vim.pack` plugin registration and plugin module loading
- [lua/plugins](lua/plugins): plugin-specific setup modules
- [after/ftplugin](after/ftplugin): filetype-specific buffer settings
- [after/indent](after/indent): indentation overrides

## Maintenance

- Start Neovim with `nvim`; missing `vim.pack` plugins are installed on startup.
- Run `:lua vim.pack.update()` or `<leader>u` to update plugins.
- Run `:TSUpdate` after updating `nvim-treesitter`.
- Run `:checkhealth vim.lsp` for LSP status.
- Keep [nvim-pack-lock.json](nvim-pack-lock.json) under version control for reproducible installs.

## Notes

- This config uses native `vim.lsp.enable()` instead of older `require("lspconfig").setup()` patterns.
- Neovim 0.12's `:lsp` command is the canonical interface for starting, stopping, and restarting LSP clients.
- Missing external executables are skipped instead of causing startup errors.
- PHP indentation is deliberately conservative in [after/ftplugin/php.lua](after/ftplugin/php.lua) and [after/indent/php.lua](after/indent/php.lua).
