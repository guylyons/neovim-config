# Popular Neovim Packages to Consider

Generated as a follow-up list for this Neovim 0.12+ `vim.pack` config.

## Current config already covers

This config already includes a solid modern Neovim baseline:

- `nvim-treesitter/nvim-treesitter`
- `neovim/nvim-lspconfig`
- `williamboman/mason.nvim`
- `williamboman/mason-lspconfig.nvim`
- `hrsh7th/nvim-cmp`
- `L3MON4D3/LuaSnip`
- `ibhagwan/fzf-lua`
- `lewis6991/gitsigns.nvim`
- `sindrets/diffview.nvim`
- `folke/which-key.nvim`
- `folke/flash.nvim`
- `NeogitOrg/neogit`
- `rachartier/tiny-inline-diagnostic.nvim`

## Strong candidates

### `stevearc/oil.nvim`

A file explorer that treats directories like editable buffers.

Why it is worth considering:

- More Neovim-native than a sidebar tree.
- Complements `fzf-lua` well: use `fzf-lua` to find files, Oil to manipulate them.
- Great for renaming, moving, creating, and deleting files from inside Neovim.

Recommended: yes.

### `folke/trouble.nvim`

A better diagnostics, references, quickfix, and location-list UI.

Why it is worth considering:

- Complements `tiny-inline-diagnostic.nvim`.
- Gives project/file-level diagnostic navigation.
- Useful for LSP-heavy workflows.

Recommended: yes.

### `kylechui/nvim-surround`

Add, change, and delete surrounding quotes, tags, parentheses, brackets, etc.

Why it is worth considering:

- Small, focused, high-value editing primitive.
- Useful for strings, HTML/Twig tags, JSX/TSX, PHP arrays, and Lua tables.

Recommended: yes.

### `numToStr/Comment.nvim`

Smart commenting with motions and Tree-sitter support.

Why it is worth considering:

- Reliable `gcc` / `gc`-style commenting.
- Cleaner than manually maintaining comment mappings across filetypes.

Recommended: yes, unless built-in commenting is already enough.

### `stevearc/conform.nvim`

Modern formatter orchestration for Neovim.

Why it is worth considering:

- Better than raw LSP formatting when using external formatters.
- Good for `stylua`, `prettier`, `php-cs-fixer`, `gofmt`, etc.
- Gives per-filetype control.

Caveat:

- Current `lua/plugins/format.lua` intentionally keeps formatting manual and LSP-based to avoid noisy diffs.
- If added, preserve manual formatting unless explicitly changing that policy.

Recommended: yes, if external formatter support is desired.

### `MeanderingProgrammer/render-markdown.nvim`

Renders Markdown more nicely inside Neovim.

Why it is worth considering:

- Useful for README files, notes, plans, docs, and AI prompt files.
- Purely quality-of-life, low-risk.

Recommended: yes, if Markdown is part of the workflow.

## Optional quality-of-life additions

### `nvim-lualine/lualine.nvim`

Popular statusline plugin.

Why it is worth considering:

- Adds richer mode, LSP, Git, filetype, and file status display.
- This config does not currently appear to have a statusline plugin.

Recommended: optional.

### `lukas-reineke/indent-blankline.nvim`

Indent guides for nested code.

Why it is worth considering:

- Helpful in Lua, PHP, TypeScript, Twig, YAML, etc.
- Purely visual.

Recommended: optional.

### `folke/todo-comments.nvim`

Highlights and lists TODO/FIXME/HACK/etc. comments.

Why it is worth considering:

- Good if code annotations are used often.
- Can pair nicely with Trouble or fuzzy pickers.

Recommended: optional.

### `windwp/nvim-autopairs`

Automatic bracket/quote pairing.

Why it is worth considering:

- More IDE-like insert-mode behavior.

Caveat:

- Autopairing is personal preference; some people find it intrusive.

Recommended: optional.

### `mfussenegger/nvim-lint`

Async linting complementary to LSP.

Why it is worth considering:

- Useful for tools whose diagnostics do not come from LSP.
- Examples: `eslint`, `phpstan`, `shellcheck`, `markdownlint`.

Recommended: optional/strong if those tools are used.

### `mfussenegger/nvim-dap`

Debug Adapter Protocol client for Neovim.

Why it is worth considering:

- Integrated breakpoints/debugging for Go, PHP, TypeScript, etc.

Recommended: only if debugging inside Neovim is desired.

## Completion and AI options

### `saghen/blink.cmp`

A newer, fast completion engine and increasingly popular alternative to `nvim-cmp`.

Why it is worth considering:

- Performance-focused.
- Batteries-included completion experience.

Caveat:

- This would replace `nvim-cmp`, not complement it.
- Current completion config is already functional.

Recommended: only if intentionally modernizing/replacing completion.

### `olimorris/codecompanion.nvim`

AI coding/chat workflows inside Neovim.

Why it is worth considering:

- More Neovim-native assistant workflow.
- Good if interactive AI chat/edit flows should live inside the editor.

Caveat:

- This config already has custom Codex-related integration in `lua/core/codex_edit.lua`.

Recommended: maybe.

### `yetone/avante.nvim`

Cursor-like AI IDE behavior inside Neovim.

Why it is worth considering:

- Very popular and feature-rich.

Caveat:

- Bigger workflow change than CodeCompanion.
- May be more than needed for a small personal config.

Recommended: maybe, only if a Cursor-like workflow is desired.

### `zbirenbaum/copilot.lua` or `github/copilot.vim`

GitHub Copilot integration.

Why it is worth considering:

- Mature Copilot support.

Recommendation:

- Prefer `copilot.lua` for Lua-native config if choosing between the two.

## Probably skip

### `folke/lazy.nvim`

Very popular plugin manager, but this config intentionally targets Neovim 0.12+ and native `vim.pack`.

Recommendation: skip unless lazy-loading/plugin-spec ergonomics become a goal.

### `nvim-telescope/telescope.nvim`

Excellent fuzzy finder, but this config already uses `fzf-lua`.

Recommendation: skip unless Telescope-specific extensions are needed.

### `nvim-tree/nvim-tree.lua` / `nvim-neo-tree/neo-tree.nvim`

Popular tree-style file explorers.

Recommendation: try `oil.nvim` first; it better fits a minimal modern config.

### `neoclide/coc.nvim` / `dense-analysis/ale`

Popular historically, but this config already uses native LSP and Mason.

Recommendation: skip.

### Full distributions

Examples:

- LazyVim
- AstroNvim
- NvChad
- LunarVim

Recommendation: skip. This is already a personal Neovim config, not a distribution-based setup.

## Suggested first batch

If adding a small, high-impact set later, start with:

1. `stevearc/oil.nvim`
2. `folke/trouble.nvim`
3. `kylechui/nvim-surround`
4. `numToStr/Comment.nvim`
5. `MeanderingProgrammer/render-markdown.nvim`

Possible second batch:

1. `stevearc/conform.nvim`
2. `mfussenegger/nvim-lint`
3. `nvim-lualine/lualine.nvim`
4. `folke/todo-comments.nvim`

Possible experiment:

- Replace `nvim-cmp` with `saghen/blink.cmp` only if completion modernization is desired.
