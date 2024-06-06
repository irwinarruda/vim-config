return {
  "nvimdev/lspsaga.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    local lspsaga = require("lspsaga")
    lspsaga.setup({
      ui = {
        code_action = "",
      },
    })
  end,
}
