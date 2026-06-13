local ok, jujutsu = pcall(require, "jujutsu-nvim")
if not ok then
	return
end

jujutsu.setup({
	diff_preset = "diffview",
})
