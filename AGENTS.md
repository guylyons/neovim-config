# Repository Guidelines

## Project Structure & Module Organization
This repository is a personal Neovim configuration for Neovim 0.12+.

- `init.lua`: entry point; loads core modules, plugins, and keymaps.
- `lua/core/options.lua`: core editor options.
- `lua/core/autocmds.lua`: search, cursor-restore, and Tree-sitter folding autocommands.
- `lua/core/diagnostics.lua`: diagnostic display settings.
- `lua/core/keymaps.lua`: custom keymaps and navigation helpers.
- `lua/core/codex_edit.lua`: Codex range-edit integration (`:CodexEdit`, `:CodexLine`).
- `lua/plugins/init.lua`: plugin registration and loading through native `vim.pack`.
- `lua/plugins/*.lua`: one file per plugin or feature area (`treesitter`, `lsp`, `format`, etc.).
- `after/ftplugin/*`: filetype-specific buffer and indentation overrides.

There is no dedicated `tests/` directory in this repo.

## Build, Test, and Development Commands
Use Neovim itself as the runtime and validation tool.

- `nvim`: start locally and let `vim.pack` install missing plugins.
- `:lua vim.pack.update()` (mapped to `<leader>u`): update plugins. `vim.pack` is a
  Lua API in 0.12 -- there is no `:PackUpdate` command. Use `vim.pack.del({"name"})`
  to remove a plugin from disk and the lockfile.
- `:TSUpdate`: update Tree-sitter parsers.
- `:checkhealth`: verify runtime dependencies (Node, LSP tools, providers).
- Startup smoke check -- loads the real config against a real file, so it catches
  runtime errors that a parse-only check misses:

      nvim --headless "+edit foo.ts" "+sleep 500m" \
        "+lua vim.print(#vim.lsp.get_clients({bufnr=0}))" +qa

## Coding Style & Naming Conventions
- Language: Lua.
- Indentation in this repo's own Lua files: tabs (stylua default). The 2-space
  `expandtab`/`shiftwidth`/`tabstop` settings in `lua/core/options.lua` are the
  editing defaults for *other* projects, not the style used here.
- Prefer small, focused modules under `lua/plugins/` with descriptive lowercase names (for example, `treesitter.lua`, `lualine.lua`).
- Keep comments brief and only where behavior is non-obvious.
- Formatting: use `stylua` for Lua changes when available.

## Testing Guidelines
There is no formal automated test suite yet. Validate changes with targeted manual checks:

- Start `nvim` and confirm startup has no errors.
- Run `:checkhealth` and `:LspInfo` after LSP/plugin changes.
- Open representative files (`.lua`, `.php`, `.ts`, `.twig`, `.yml`) to verify highlighting, indentation, and formatting.

## Commit & Pull Request Guidelines
Git history shows short, focused commit subjects (for example, `treesitter update`, `keybinding update`, `indentation`). Follow that style:

- Use concise, imperative commit messages.
- Keep each commit scoped to one logical change.
- In PRs, include: purpose, key files changed, validation steps, and any relevant screenshots for visible UI/keymap behavior.

## Reference Material
When developing you will use source code as your guide to understand how to write the most modern standards based
code for NeoVim plugins, configuration and documentation.

You are detail focussed and only use what is the most current.

- https://github.com/neovim/neovim
- Before you work on a function, method, anything, you ALWAYS check the repo to see whether or not it is deprecated. If it is, you replace it with newer option.
