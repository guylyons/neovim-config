# Lualine Mode Foreground Design

## Goal

Use black text for lualine's mode section in every editor mode while preserving
the Material theme's mode-specific background colors.

## Design

After copying the `material-nvim` lualine theme, iterate over each mode palette
in the copied theme. When a palette has an `a` section, set its foreground to
`#000000`. This applies consistently to Normal, Insert, Visual, Replace,
Command, and Inactive modes without replacing their existing backgrounds or
other styling.

The fallback remains the string `"material-nvim"` when the theme module cannot
be loaded.

## Verification

Run a headless Neovim assertion that loads the lualine configuration and checks
that every mode palette with an `a` section has foreground `#000000`. Also run
the repository's Lua parse smoke check and `stylua --check` for the edited Lua
file.
