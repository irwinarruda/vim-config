local s, rainbow = pcall(require, "rainbow-delimiters.setup")
if not s then
  return
end

vim.cmd([[
  highlight CustomRainbowYellow guifg=#FFD700
  highlight CustomRainbowPink guifg=#DA70D6
  highlight CustomRainbowBlue guifg=#179FFF
]])

rainbow.setup({
  query = {
    svelte = "rainbow-parens",
    vue = "rainbow-parens",
    html = "rainbow-parens",
    javascript = "rainbow-parens",
    tsx = "rainbow-parens",
    typescript = "rainbow-parens",
  },
  highlight = {
    "CustomRainbowYellow",
    "CustomRainbowPink",
    "CustomRainbowBlue",
  },
})
