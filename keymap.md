# Keymaps

Full reference for every custom mapping in this config. `<leader>` is `<Space>` (set in [lua/core/options.lua](lua/core/options.lua)); `<localleader>` is `\` but nothing here uses it. Press `<leader>?` at any time to open which-key for the current buffer.

Sources: [lua/core/keymaps.lua](lua/core/keymaps.lua), [lua/plugins/whichkey.lua](lua/plugins/whichkey.lua), [lua/plugins/gitsigns.lua](lua/plugins/gitsigns.lua), [lua/plugins/format.lua](lua/plugins/format.lua).

## General

| Keys | Mode | Action |
| --- | --- | --- |
| `jj` | Insert | Leave insert mode |
| `<leader><CR>` | Normal | Write buffer |
| `<leader>q` | Normal | Quit window |
| `<leader>Q` / `<leader>;` | Normal | Quit all |
| `<leader>w` | Normal | Pick a window (window-picker) |
| `<leader>O` | Normal | Open the containing folder (`vim.ui.open`) |
| `<leader>u` | Normal | Update plugins (`vim.pack.update()`) |
| `<leader>t` | Normal | Open the undo tree (`nvim.undotree`); history persists across sessions |
| `<D-g>` | Normal, Insert, Visual, Select, Cmdline | Escape (Cmd+G) |
| `<leader>?` | Normal | Show buffer-local keymaps (which-key) |

## Navigation & Search

| Keys | Mode | Action |
| --- | --- | --- |
| `-` / `<leader>j` | Normal | Open netrw for the current file's directory, cursor on the file just left |
| `<leader>e` | Normal | Prompt `:edit` from the current buffer's directory |
| `<leader>s` | Normal, Visual, Operator-pending | Flash jump |
| `S` | Normal, Visual, Operator-pending | Flash Tree-sitter jump |

## Fzf-lua

All fzf pickers run rooted at the nearest enclosing Git worktree unless noted.

| Keys | Mode | Action |
| --- | --- | --- |
| `<leader>f` / `<leader>p` | Normal | Files (project root) |
| `<leader>P` | Normal | Files (current buffer's directory) |
| `<leader>A` | Normal | All files, including gitignored/hidden |
| `<leader>F` | Normal | Git files |
| `<leader>c` | Normal | Commands |
| `<leader>g` | Normal | Live grep (project root) |
| `<leader>G` | Normal, Visual | Live grep seeded with the visual selection or word under cursor, including gitignored/hidden |
| `<leader>*` | Normal | Grep word under cursor |
| `<leader>b` | Normal | Buffers |
| `<leader>k` | Normal | Lines in current buffer (exact match) |
| `<leader>r` | Normal | Recent files |
| `<leader>.` | Normal | Resume last picker |
| `<leader>d` | Normal | Document diagnostics |
| `<leader>D` | Normal | Workspace diagnostics |
| `<leader>S` | Normal | Git status |
| `<leader>h` | Normal | Help tags |
| `<leader>v` | Normal | Registers |
| `<leader>ls` | Normal | LSP document symbols |
| `<leader>lS` | Normal | LSP workspace symbols |

## LSP

`grr`/`gri`/`grt` override Neovim's built-in `gr*` maps in place (so a bare `gr` doesn't stall for `timeoutlen`); `gi` and `gt` keep their normal meanings (insert at last insert position, next tabpage).

| Keys | Mode | Action |
| --- | --- | --- |
| `gd` | Normal | Go to definition; jumps straight to the source file for a PHP `use Drupal\...` import line, otherwise `vim.lsp.buf.definition()` |
| `grr` | Normal | Go to references (fzf-lua) |
| `gri` | Normal | Go to implementations (fzf-lua) |
| `grt` | Normal | Go to type definitions (fzf-lua) |
| `K` | Normal | Hover documentation |
| `<leader>rn` | Normal | Rename symbol |
| `<leader>a` | Normal, Visual | Code action |
| `<leader>li` | Normal | `:checkhealth vim.lsp` |
| `<leader>lh` | Normal | `:checkhealth fzf_lua` |

## Formatting

| Keys | Mode | Action |
| --- | --- | --- |
| `<leader>lf` | Normal, Visual | Format the current buffer (same as `:Format`) |

## Git

| Keys | Mode | Action |
| --- | --- | --- |
| `<leader>m` | Normal | Open Neogit |
| `<leader>J` | Normal | Open Jujutsu log (`:JJ`) |
| `]h` / `[h` | Normal | Next / previous git hunk (gitsigns, buffer-local) |
| `<leader>Hp` | Normal | Preview hunk (gitsigns, buffer-local) |
| `<leader>Hs` | Normal | Stage hunk (gitsigns, buffer-local) |
| `<leader>Hr` | Normal | Reset hunk (gitsigns, buffer-local) |

## AI Edit

Prompts for an instruction, then rewrites text in place. `<leader>i` is bound to Claude; the same underlying flow also powers Codex through `:CodexLine`/`:CodexEdit`, which have no default keymap.

| Keys | Mode | Action |
| --- | --- | --- |
| `<leader>i` | Normal | Ask Claude to rewrite the current line (`:AiLine`) |
| `<leader>i` | Visual | Ask Claude to rewrite the selection (`:AiEdit`) |

## Commands without a default keymap

| Command | Action |
| --- | --- |
| `:Format` | Format the current buffer through an attached LSP client (same as `<leader>lf`) |
| `:CodexLine` | Ask Codex to replace the current line |
| `:CodexEdit` | Ask Codex to replace the selected text |
