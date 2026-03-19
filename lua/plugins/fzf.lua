return {
	"ibhagwan/fzf-lua",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	opts = {},
	keys = function()
		local function get_cwd()
			if vim.bo.filetype == "netrw" and vim.b.netrw_curdir then
				return vim.b.netrw_curdir
			end

			local bufname = vim.api.nvim_buf_get_name(0)
			if bufname ~= "" then
				return vim.fn.fnamemodify(bufname, ":h")
			end

			return vim.uv.cwd()
		end

		local function get_root()
			local git_root = vim.fs.find(".git", {
				path = get_cwd(),
				upward = true,
				type = "directory",
			})[1]
			if git_root then
				return vim.fs.dirname(git_root)
			end

			return vim.uv.cwd()
		end

		return {
			{ "<leader>b", function() require("fzf-lua").buffers() end, desc = "FZF buffers" },
			{ "<leader>f", function() require("fzf-lua").files() end, desc = "FZF files" },
			{
				"<leader>g",
				function()
					require("fzf-lua").live_grep({ cwd = get_cwd() })
				end,
				desc = "FZF live grep (current dir)",
			},
			{
				"<leader>G",
				function()
					require("fzf-lua").live_grep({ cwd = get_root() })
				end,
				desc = "FZF live grep (project root)",
			},
			{ "<leader>h", function() require("fzf-lua").help_tags() end, desc = "FZF help tags" },
			{
				"<leader>k",
				function()
					require("fzf-lua").blines({
						fzf_opts = {
							["--exact"] = "",
						},
					})
				end,
				desc = "FZF lines (exact match)",
			},
			{
				"<leader>p",
				function()
					require("fzf-lua").files({ cwd = get_cwd() })
				end,
				desc = "FZF files (current dir)",
			},
			{
				"<leader>P",
				function()
					require("fzf-lua").files({ cwd = get_root() })
				end,
				desc = "FZF files (project root)",
			},
			{ "<leader>v", function() require("fzf-lua").registers() end, desc = "FZF registers" },
		}
	end,
}
