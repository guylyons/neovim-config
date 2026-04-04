vim.pack.add({
  "https://github.com/NeogitOrg/neogit",
})

local ok, neogit = pcall(require, "neogit")
if not ok then
  return
end

neogit.setup({})
