" Keep Lua on Neovim's built-in indent engine.
" Treesitter indentation for Lua is less reliable here and can override this late.
setlocal indentexpr=GetLuaIndent()
