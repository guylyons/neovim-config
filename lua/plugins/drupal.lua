return {
	"jdrupal-dev/drupal.nvim",
	dependencies = { "nvim-lua/plenary.nvim" },
	ft = { "php", "twig" },
	config = function()
		local ok, drupal = pcall(require, "drupal")
		if not ok then
			return
		end
		drupal.setup({
			services_cmp_trigger_character = "@",
			get_drush_executable = function(_current_dir)
				return "drush"
			end,
		})
	end,
}
