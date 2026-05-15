vim.g.user_emmet_install_global = 0
vim.g.user_emmet_mode = "inv"
vim.g.user_emmet_expandabbr_key = "<C-y>,"
vim.g.user_emmet_settings = {
	twig = {
		extends = "html",
	},
}

local group = vim.api.nvim_create_augroup("user-emmet", { clear = true })
local filetypes = {
	"astro",
	"css",
	"eruby",
	"html",
	"htmlangular",
	"htmldjango",
	"javascriptreact",
	"less",
	"php",
	"sass",
	"scss",
	"svelte",
	"twig",
	"typescriptreact",
	"vue",
	"xml",
}

local filetype_set = {}
for _, ft in ipairs(filetypes) do
	filetype_set[ft] = true
end

local function enable_emmet(bufnr)
	local ft = vim.bo[bufnr].filetype
	if not filetype_set[ft] then
		return
	end

	vim.api.nvim_buf_call(bufnr, function()
		vim.cmd("EmmetInstall")
	end)
end

vim.api.nvim_create_autocmd("FileType", {
	group = group,
	pattern = filetypes,
	callback = function(event)
		enable_emmet(event.buf)
	end,
})

enable_emmet(0)
