local opt = vim.opt

-- line
opt.relativenumber = true
opt.number = true
opt.cmdheight = 0

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
opt.inccommand = "split"
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
opt.scrolloff = 6
opt.updatetime = 50
opt.colorcolumn = { "80", "120" }

vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("HighlightOnYank", { clear = false }),
  desc = "Hightlight selection on yank",
  pattern = "*",
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 100 })
  end,
})

-- adding templ filetype for golang templates
vim.filetype.add({ extension = { templ = "templ" } })
