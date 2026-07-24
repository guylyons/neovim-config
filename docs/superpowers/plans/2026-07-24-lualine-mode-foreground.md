# Lualine Mode Foreground Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Use black text in lualine's mode section for every editor mode.

**Architecture:** Continue copying the `material-nvim` theme before passing it
to lualine. Iterate over the copied mode palettes and override only section
`a`'s foreground, preserving every mode-specific background and style.

**Tech Stack:** Lua, Neovim 0.12+, lualine.nvim, material.nvim

## Global Constraints

- Set each available mode palette's section `a` foreground to `#000000`.
- Preserve mode-specific backgrounds and all other Material theme styling.
- Preserve the `"material-nvim"` fallback when the theme module cannot load.

---

### Task 1: Apply Black Foreground to Every Lualine Mode

**Files:**
- Modify: `lua/plugins/lualine.lua:6-11`
- Test: headless Neovim assertions; no persistent test file

**Interfaces:**
- Consumes: `require("lualine.themes.material-nvim")`, whose result maps mode
  names to section palettes.
- Produces: `theme`, a copied lualine theme whose available `a` sections all
  have `fg = "#000000"`.

- [x] **Step 1: Run the failing mode-foreground assertion**

```bash
nvim --headless "+lua local cfg=require('lualine').get_config(); local theme=cfg.options.theme; for _,mode in ipairs({'normal','insert','visual','replace','command','inactive'}) do assert(theme[mode] and theme[mode].a and theme[mode].a.fg == '#000000', mode .. ' mode foreground is ' .. tostring(theme[mode] and theme[mode].a and theme[mode].a.fg)) end; print('all lualine mode foregrounds are black')" +qa
```

Expected: FAIL on `insert mode foreground is NONE`, proving only Normal mode is
currently overridden.

- [x] **Step 2: Implement the minimal theme override**

Replace the single Normal-mode assignment with:

```lua
for _, palette in pairs(theme) do
  if type(palette) == "table" and palette.a then
    palette.a.fg = "#000000"
  end
end
```

- [x] **Step 3: Run the mode-foreground assertion**

```bash
nvim --headless "+lua local cfg=require('lualine').get_config(); local theme=cfg.options.theme; for _,mode in ipairs({'normal','insert','visual','replace','command','inactive'}) do assert(theme[mode] and theme[mode].a and theme[mode].a.fg == '#000000', mode .. ' mode foreground is ' .. tostring(theme[mode] and theme[mode].a and theme[mode].a.fg)) end; print('all lualine mode foregrounds are black')" +qa
```

Expected: PASS and print `all lualine mode foregrounds are black`.

- [x] **Step 4: Run repository validation**

```bash
nvim --headless -u NONE "+lua assert(loadfile('init.lua')); print('ok')" +qa
stylua --check lua/plugins/lualine.lua
git diff --check
```

Expected: each command exits zero; Neovim prints `ok`; the formatting and diff
checks produce no errors.

- [x] **Step 5: Commit the implementation**

```bash
git add lua/plugins/lualine.lua
git commit -m "update lualine mode colors"
```
