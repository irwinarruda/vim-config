return {
  "hiphish/rainbow-delimiters.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local rainbow = require("rainbow-delimiters.setup")

    vim.cmd([[
      hi! CustomRainbowYellow guifg=#FFD700
      hi! CustomRainbowPink guifg=#DA70D6
      hi! CustomRainbowBlue guifg=#179FFF
    ]])

    rainbow.setup({
      query = {
        svelte = "rainbow-parens",
        vue = "rainbow-parens",
        html = "rainbow-parens",
        javascript = "rainbow-parens",
        tsx = "rainbow-parens",
        typescript = "rainbow-parens",
        templ = "rainbow-parens"
      },
      highlight = {
        "CustomRainbowYellow",
        "CustomRainbowPink",
        "CustomRainbowBlue",
      },
    })
  end,
}
