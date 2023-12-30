# Neovim Config

## Prepare

Copy the repo code to the `.config`.

```bash
# MacOS
$ rm -rf ~/.config/nvim
$ cp ./nvim ~/.config/nvim
```

Copy the `.config` code to the repo.

```bash
# MacOS
$ rm -rf ./nvim
$ cp ~/.config/nvim ./nvim
```

## Dracula Pro

For good syntax highlighting using the dracula_pro theme, you should replace the `if has('nvim')` with the following code near the end of the file `/colors/dracula_pro_base.vim`:

```vim
if has('nvim')
  hi! link SpecialKey DraculaRed
  hi! link LspReferenceText DraculaSelection
  hi! link LspReferenceRead DraculaSelection
  hi! link LspReferenceWrite DraculaSelection
  " Link old 'LspDiagnosticsDefault*' hl groups
  " for backward compatibility with neovim v0.5.x
  hi! link LspDiagnosticsDefaultInformation DiagnosticInfo
  hi! link LspDiagnosticsDefaultHint DiagnosticHint
  hi! link LspDiagnosticsDefaultError DiagnosticError
  hi! link LspDiagnosticsDefaultWarning DiagnosticWarn
  hi! link LspDiagnosticsUnderlineError DiagnosticUnderlineError
  hi! link LspDiagnosticsUnderlineHint DiagnosticUnderlineHint
  hi! link LspDiagnosticsUnderlineInformation DiagnosticUnderlineInfo
  hi! link LspDiagnosticsUnderlineWarning DiagnosticUnderlineWarn
  hi! link LspInlayHint DraculaInlayHint

  hi! link DiagnosticInfo DraculaCyan
  hi! link DiagnosticHint DraculaCyan
  hi! link DiagnosticError DraculaError
  hi! link DiagnosticWarn DraculaOrange
  hi! link DiagnosticUnderlineError DraculaErrorLine
  hi! link DiagnosticUnderlineHint DraculaInfoLine
  hi! link DiagnosticUnderlineInfo DraculaInfoLine
  hi! link DiagnosticUnderlineWarn DraculaWarnLine

  hi! link WinSeparator DraculaWinSeparator
  if has('nvim-0.9')
    hi! link  @lsp.type.class DraculaCyan
    hi! link  @lsp.type.decorator DraculaGreen
    hi! link  @lsp.type.enum DraculaCyan
    hi! link  @lsp.type.enumMember DraculaPurple
    hi! link  @lsp.type.function DraculaGreen
    hi! link  @lsp.type.interface DraculaCyan
    hi! link  @lsp.type.macro DraculaCyan
    hi! link  @lsp.type.method DraculaGreen
    hi! link  @lsp.type.namespace DraculaCyan
    hi! link  @lsp.type.parameter DraculaOrangeItalic
    hi! link  @lsp.type.property DraculaFg
    hi! link  @lsp.type.struct DraculaCyan
    hi! link  @lsp.type.type DraculaCyanItalic
    hi! link  @lsp.type.typeParameter DraculaPink
    hi! link  @lsp.type.variable DraculaFg
    hi! link  @lsp.mod.readonly DraculaPurple
    hi! link  @lsp.typemod.variable.globalScope DraculaPurple
  endif
else
  hi! link SpecialKey DraculaSubtle
endif
```

[Note: the code above is a modified version from the open source dracula vim theme. They just did not update the pro version yet]
