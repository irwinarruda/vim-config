return {
  "nvim-lualine/lualine.nvim",
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
    })
  end,
}
