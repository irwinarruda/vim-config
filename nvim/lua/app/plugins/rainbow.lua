return {
  "hiphish/rainbow-delimiters.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    vim.api.nvim_set_hl(0, "CustomRainbowYellow", { fg = "#FFD700" })
    vim.api.nvim_set_hl(0, "CustomRainbowPink", { fg = "#DA70D6" })
    vim.api.nvim_set_hl(0, "CustomRainbowBlue", { fg = "#179FFF" })

    require("rainbow-delimiters.setup").setup({
      query = {
        svelte = "rainbow-parens",
        vue = "rainbow-parens",
        html = "rainbow-parens",
        javascript = "rainbow-parens",
        tsx = "rainbow-parens",
        typescript = "rainbow-parens",
        templ = "rainbow-parens",
      },
      highlight = {
        "CustomRainbowYellow",
        "CustomRainbowPink",
        "CustomRainbowBlue",
      },
    })
  end,
}
