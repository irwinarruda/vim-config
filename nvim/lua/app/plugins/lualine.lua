return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "folke/noice.nvim" },
  event = "VeryLazy",
  config = function()
    local lualine = require("lualine")
    local lualine_dracula = require("lualine.themes.dracula")

    local theme
    if string.find(vim.g.colors_name, "tokyonight") then
      theme = "tokyonight"
    else
      theme = lualine_dracula
    end

    lualine.setup({
      options = {
        theme = theme,
      },
      sections = {
        lualine_x = {
          {
            require("noice").api.statusline.mode.get,
            cond = require("noice").api.statusline.mode.has,
            color = { fg = "#ff9e64" },
          },
        },
      },
    })
  end,
}
