local opt = vim.opt

-- line numbers
opt.relativenumber = true
opt.number = true

-- tabs & indentation
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true
opt.smartindent = true

-- line wrapping
opt.wrap = false

-- search settings
opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true

-- apperance
opt.termguicolors = true
opt.smartcase = true

-- backspace
opt.backspace = "indent,eol,start"
opt.eol = true

-- clipboard
opt.clipboard:append("unnamedplus")

-- split windows
opt.splitright = true
opt.splitbelow = true

-- gutter
opt.signcolumn = "yes"
opt.scrolloff = 10
opt.updatetime = 50
opt.colorcolumn = "80"
