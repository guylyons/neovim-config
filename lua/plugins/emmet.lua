return {
	"mattn/emmet-vim",
	init = function()
		vim.g.user_emmet_install_global = 0
		vim.g.user_emmet_mode = "inv"
		vim.g.user_emmet_expandabbr_key = "<Tab>"
		vim.g.user_emmet_settings = {
			php = {
				extends = "html",
			},
			twig = {
				extends = "html",
			},
			javascriptreact = {
				extends = "jsx",
			},
			typescriptreact = {
				extends = "jsx",
			},
		}
	end,
	config = function()
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

		vim.api.nvim_create_autocmd("FileType", {
			group = group,
			pattern = filetypes,
			callback = function(event)
				vim.cmd("EmmetInstall")
				vim.keymap.set(
					"i",
					"<Tab>",
					'<C-r>=emmet#isExpandable() ? emmet#util#closePopup() . emmet#expandAbbr(0,"") : "\\<Tab>"<CR>',
					{
						buffer = event.buf,
						noremap = true,
						silent = true,
						desc = "Expand Emmet abbreviation",
					}
				)
			end,
		})
	end,
}
