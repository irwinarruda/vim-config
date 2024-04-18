return {
  "folke/neodev.nvim",
  event = { "BufReadPre *.lua", "BufNewFile *.lua" },
  config = function()
    local neodev = require("neodev")
    neodev.setup({
      library = {
        plugins = { "nvim-dap-ui", "nvim-treesitter", "plenary.nvim", "telescope.nvim", "lspsaga.nvim" },
        types = true,
      },
    })
  end,
}
