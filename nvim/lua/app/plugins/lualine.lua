return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "folke/noice.nvim" },
  event = "VeryLazy",
  opts = function()
    local noice_mode = require("noice").api.statusline.mode

    return {
      options = {
        theme = ({ favo = "favo", barro = "barro" })[(vim.g.colors_name or ""):match("^(%a+)%-")] or "dracula",
      },
      sections = {
        lualine_x = {
          {
            noice_mode.get,
            cond = noice_mode.has,
            color = { fg = "#ff9e64" },
          },
        },
      },
    }
  end,
}
