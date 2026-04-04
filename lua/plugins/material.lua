vim.pack.add({
  "https://github.com/marko-cerovac/material.nvim",
})

local ok, material = pcall(require, "material")
if not ok then
  return
end

material.setup({
  contrast = {
    terminal = false,
    sidebars = true,
    floating_windows = true,
  },
  styles = {
    comments = { italic = true },
    keywords = { bold = true },
    functions = { bold = true, italic = true },
  },
})

vim.cmd("colorscheme material-deep-ocean")
