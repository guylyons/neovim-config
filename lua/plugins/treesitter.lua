return {
  "nvim-treesitter/nvim-treesitter",
  config = function()
    local parser_config = require "nvim-treesitter.parsers".get_parser_configs()
  end
}
