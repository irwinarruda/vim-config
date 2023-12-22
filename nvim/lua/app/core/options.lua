local opt = vim.opt

-- line numbers
opt.relativenumber = true
opt.number = true

-- tabs & indentation
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true

-- line wrapping
opt.wrap = false
opt.cursorline = false
-- opt.guicursor = 'n-v-c:block-Cursor/lCursor,ve:ver35-Cursor,o:hor50-Cursor,i-ci:ver25-Cursor/lCursor,r-cr:hor20-Cursor/lCursor,sm:block-Cursor-blinkwait175-blinkoff150-blinkon175'

-- search settings
opt.ignorecase = true
opt.smartcase = true

-- apperance
-- opt.background = 'light'
opt.termguicolors = true
opt.smartcase = true

-- backspace
opt.backspace = 'indent,eol,start'

-- clipboard
opt.clipboard:append('unnamedplus')

-- split windows
opt.splitright = true
opt.splitbelow = true

-- opt.iskeyword:append('-')
-- gutter
opt.signcolumn = 'yes'



