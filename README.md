# Vim Configs

Vim configs for the main editors I use. Some of them are more complex than others depending on how much I use the editor.

## Neovim Config

I'm trying to create a better and more concise development environment using Neovim. It's been a challenge, but I'm satified with the config I have right now.

### Prepare

Copy the repo code to the `.config`.

```bash
# MacOS
$ rm -rf ~/.config/nvim
$ cp -r $PATH_TO_REPO/nvim ~/.config/nvim
```

Copy the `.config` code to the repo.

```bash
# MacOS
$ rm -rf $PATH_TO_REPO/nvim
$ cp -r ~/.config/nvim $PATH_TO_REPO/nvim
```

### Dracula Pro

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
    " Treesitter
    hi! link @definition.constant DraculaPurple
    hi! link @symbol DraculaCyanItalic
    hi! link @error DraculaRed
    hi! link @punctuation.bracket DraculaFg
    hi! link @punctuation.special DraculaFg
    hi! link @comment DraculaComment
    hi! link @constant DraculaPurple
    hi! link @constant.builtin DraculaPurple
    hi! link @constant.macro DraculaPurple
    hi! link @string.regex DraculaRed
    hi! link @string DraculaYellow
    hi! link @character DraculaYellow
    hi! link @number DraculaPurple
    hi! link @boolean DraculaPurple
    hi! link @float DraculaPurple
    hi! link @annotation DraculaPink
    hi! link @attribute DraculaGreen
    hi! link @attribute.builtin DraculaGreen
    hi! link @namespace DraculaCyanItalic
    hi! link @function.builtin DraculaGreen
    hi! link @function DraculaGreen
    hi! link @function.macro DraculaGreen
    hi! link @parameter DraculaOrangeItalic
    hi! link @method DraculaGreen
    hi! link @field DraculaFg
    hi! link @property DraculaFg
    hi! link @constructor DraculaPink
    hi! link @constructor.tsx DraculaCyan
    hi! link @conditional DraculaPink
    hi! link @repeat DraculaPink
    hi! link @label DraculaPink
    hi! link @keyword DraculaPink
    hi! link @keyword.function DraculaPink
    hi! link @keyword.operator DraculaPink
    hi! link @operator DraculaPink
    hi! link @exception DraculaPink
    hi! link @type DraculaCyanItalic
    hi! link @type.builtin DraculaCyanItalic
    hi! link @type.qualifier DraculaPink
    hi! link @storageClass DraculaCyan
    hi! link @structure DraculaCyan
    hi! link @include DraculaPink
    hi! link @variable DraculaPurple
    hi! link @variable.builtin DraculaPurpleItalic
    hi! link @tag DraculaPink
    hi! link @tag.delimiter DraculaFg
    hi! link @tag.attribute DraculaGreen

    " LSP
    hi! link @lsp.type.class DraculaCyan
    hi! link @lsp.type.function DraculaGreen
    hi! link @lsp.type.macro DraculaCyan
    hi! link @lsp.type.method DraculaGreen
    hi! link @lsp.type.struct DraculaCyan
    hi! link @lsp.type.type DraculaCyanItalic
    hi! link @lsp.type.typeParameter DraculaFg
    hi! link @lsp.type.boolean DraculaPurple
    hi! link @lsp.type.builtinType DraculaCyan
    hi! link @lsp.type.comment DraculaComment
    hi! link @lsp.type.decorator DraculaGreen
    hi! link @lsp.type.enum DraculaCyan
    hi! link @lsp.type.enumMember DraculaPurple
    hi! link @lsp.type.generic DraculaCyan
    hi! link @lsp.type.interface DraculaCyanItalic
    hi! link @lsp.type.keyword DraculaPink
    hi! link @lsp.type.lifetime DraculaPink
    hi! link @lsp.type.namespace DraculaCyan
    hi! link @lsp.type.number DraculaPurple
    hi! link @lsp.type.operator DraculaPink
    hi! link @lsp.type.parameter DraculaOrangeItalic
    hi! link @lsp.type.property DraculaFg
    hi! link @lsp.type.selfKeyword DraculaPurple
    hi! link @lsp.type.selfTypeKeyword DraculaPurple
    hi! link @lsp.type.string DraculaYellow
    hi! link @lsp.type.typeAlias DraculaPink
    hi! link @lsp.type.unresolvedReference DraculaRed
    hi! link @lsp.type.variable DraculaPurple
    hi! link @lsp.type.variable.builtin DraculaPurple
    hi! link @lsp.typemod.class.defaultLibrary DraculaCyan
    hi! link @lsp.typemod.enum.defaultLibrary DraculaCyan
    hi! link @lsp.typemod.enumMember.defaultLibrary DraculaPurple
    hi! link @lsp.typemod.function.defaultLibrary DraculaGreen
    hi! link @lsp.typemod.keyword.async DraculaPink
    hi! link @lsp.typemod.keyword.injected DraculaPink
    hi! link @lsp.typemod.macro.defaultLibrary DraculaGreen
    hi! link @lsp.typemod.method.defaultLibrary DraculaGreen
    hi! link @lsp.typemod.operator.injected DraculaGreen
    hi! link @lsp.typemod.string.injected DraculaYellow
    hi! link @lsp.typemod.struct.defaultLibrary DraculaCyan
    hi! link @lsp.typemod.type.defaultLibrary DraculaCyanItalic
    hi! link @lsp.typemod.typeAlias.defaultLibrary DraculaPink
    hi! link @lsp.typemod.variable.callable DraculaGreen
    hi! link @lsp.typemod.variable.defaultLibrary DraculaFg
    hi! link @lsp.typemod.variable.injected DraculaPurple
    hi! link @lsp.typemod.variable.static DraculaPurple
  endif
else
  hi! link SpecialKey DraculaSubtle
endif
```

[Note: the code above is a modified version from the open source dracula vim theme. They just did not update the pro version yet]

### TODOS

- [x] Add debugger.
- [ ] Add Git lens.
