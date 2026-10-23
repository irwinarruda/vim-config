local opt = vim.opt

-- nvim-tree replaces netrw; this has to run before any plugin loads
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- line
opt.relativenumber = true
opt.number = true
-- opt.cmdheight = 0

-- tabs & indentation
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.smartindent = true

-- line wrapping
opt.wrap = false

-- search settings
opt.ignorecase = true
opt.smartcase = true
opt.inccommand = "split"

-- apperance
opt.termguicolors = true

-- native completion popup (blink.cmp draws its own menu)
opt.completeopt = "menu,menuone"

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
  group = vim.api.nvim_create_augroup("HighlightOnYank", { clear = true }),
  desc = "Hightlight selection on yank",
  callback = function()
    vim.hl.on_yank({ higroup = "IncSearch", timeout = 150 })
  end,
})
