# Repository Guidelines

## Project Structure & Module Organization
This repository is a personal Neovim configuration for Neovim 0.12+.

- `init.lua`: entry point; loads settings, plugins, keymaps, and completion config.
- `lua/settings.lua`: core editor options, filetype autocommands, environment/PATH bootstrap.
- `lua/plugin_manager.lua`: plugin registration and loading through native `vim.pack`.
- `lua/plugins/*.lua`: one file per plugin or feature area (`treesitter`, `lspconfig`, `conform`, etc.).
- `lua/keybindings.lua`, `lua/cmp-config.lua`: keymaps and completion behavior.

There is no dedicated `tests/` directory in this repo.

## Build, Test, and Development Commands
Use Neovim itself as the runtime and validation tool.

- `nvim`: start locally and let `vim.pack` install missing plugins.
- `:PackUpdate`: update plugins managed by `vim.pack`.
- `:TSUpdate`: update Tree-sitter parsers.
- `:checkhealth`: verify runtime dependencies (Node, LSP tools, providers).
- `nvim --headless -u NONE "+lua assert(loadfile('init.lua')); print('ok')" +qa`: quick Lua parse smoke check.

## Coding Style & Naming Conventions
- Language: Lua.
- Indentation: 2 spaces (`expandtab`, `shiftwidth=2`, `tabstop=2`).
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
