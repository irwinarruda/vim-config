if vim.g.neovide then
  vim.o.guifont = "FiraCode Nerd Font Mono:h12"
  vim.g.neovide_cursor_animation_length = 0.10
  vim.g.neovide_cursor_trail_size = 0.5
  vim.g.neovide_cursor_vfx_mode = "pixiedust"
  vim.g.neovide_cursor_vfx_mode = "ripple"
  vim.g.neovide_input_macos_alt_is_meta = false
end

local dracula_pro_path = vim.fn.stdpath("data") .. "/themes/dracula_pro"

return {
  {
    "folke/tokyonight.nvim",
    priority = 1000,
    enabled = false,
    config = function()
      vim.cmd([[colorscheme tokyonight-moon]])
      vim.cmd([[
        hi! link @lsp.typemod.variable.readonly Constant
        hi! link @lsp.type.extensionMethodName.cs Function
        hi! link @lsp.type.constantName.cs Constant
      ]])
    end,
  },
  {
    dir = dracula_pro_path,
    priority = 1000,
    enabled = true,
    config = function()
      --[[
        ** Available themes: **
          dracula_pro
          dracula_pro_blade
          dracula_pro_buffy
          dracula_pro_lincoln
          dracula_pro_morbius
          dracula_pro_van_helsing
      ]]
      vim.cmd("syntax enable")
      vim.cmd("let g:dracula_colorterm = 0")
      vim.cmd("colorscheme dracula_pro")
      vim.cmd([[
        " Default TS
        hi! link @type DraculaCyan
        hi! link @attribute DraculaFg
        hi! link @type.builtin DraculaCyan
        hi! link @variable.member DraculaFg
        hi! link @module.typescript DraculaFg
        hi! link @module.javascript DraculaFg
        hi! link @module.go DraculaFg
        hi! link @markup.link.label DraculaFg
        " Default LSP
        hi! link @lsp.mod.variable.readonly Constant
        hi! link @lsp.mod.global Constant
        hi! link @lsp.mod.defaultLibrary Constant
        hi! link @lsp.type.property DraculaFg
        hi! link @lsp.type.typeParameter DraculaCyanItalic
        hi! link @lsp.typemod.variable.readonly Constant
        hi! link @lsp.typemod.variable.defaultLibrary Constant
        hi! link @lsp.typemod.function.defaultLibrary.lua DraculaGreen
        hi! link @lsp.typemod.method.defaultLibrary DraculaGreen
        hi! link @lsp.typemod.interface.defaultLibrary DraculaCyan
        hi! link @lsp.typemod.class.defaultLibrary DraculaCyan
        hi! link @lsp.typemod.typeParameter.declaration DraculaCyanItalic
        hi! link @lsp.typemod.type.defaultLibrary DraculaCyan
        hi! link @lsp.typemod.function.defaultLibrary DraculaCyan
        " Javascript/Typescript
        hi! link @constructor.typescript DraculaPink
        hi! link @constructor.javascript DraculaPink
        hi! link @constructor.tsx DraculaPink

        " JSON
        hi! link @property.json DraculaCyan
        " CSS
        hi! link @punctuation.delimiter.css DraculaFg
        hi! link @type.css DraculaGreen
        hi! link @string.css DraculaPink
        " CS
        hi! link @module.c_sharp DraculaCyan
      ]])
      vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
      vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
    end,
  },
}
