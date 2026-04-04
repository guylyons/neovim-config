vim.pack.add({
  "https://github.com/pmizio/typescript-tools.nvim",
})

local ok, typescript_tools = pcall(require, "typescript-tools")
if not ok then
  return
end

typescript_tools.setup({})
