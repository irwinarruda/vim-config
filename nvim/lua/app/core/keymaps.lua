vim.g.mapleader = " "

local keymap = vim.keymap

-- Terminal
keymap.set("t", "<C-Space>", "<C-\\><C-n>", { silent = true })
-- Lines
keymap.set("n", "<leader>o", "o<Esc>")
keymap.set("n", "<leader>O", "O<Esc>")
-- Remove highlight
keymap.set("n", "<leader><Esc>", ":nohlsearch<CR>")
-- Increment and decrement
keymap.set("n", "<leader>+", "<C-a>")
keymap.set("n", "<leader>-", "<C-x>")
-- Removes buffer when paste
keymap.set("n", "x", "_x")
keymap.set("n", "<leader>p", '"_dP', { noremap = true })
keymap.set("v", "<leader>p", '"_dP', { noremap = true })
keymap.set("n", "<leader>d", '"_d', { noremap = true })
keymap.set("v", "<leader>d", '"_d', { noremap = true })
keymap.set("v", "<leader>c", '"_c', { noremap = true })
keymap.set("n", "<leader>s", '"_s', { noremap = true })
-- Move blocks of code
keymap.set("v", "J", ":m '>+1<CR>gv=gv")
keymap.set("v", "K", ":m '<-2<CR>gv=gv")
keymap.set("v", ">", ">gv")
keymap.set("v", "<", "<gv")
keymap.set("v", "y", "y`]")
-- Ctrl D with cursor in the middle
keymap.set("n", "<C-d>", "<C-d>zz")
keymap.set("n", "<C-u>", "<C-u>zz")
keymap.set("n", "n", "nzzzv")
keymap.set("n", "N", "Nzzzv")

-- Split windows
keymap.set("n", "<leader>wl", "<C-w>v") -- split window right
keymap.set("n", "<leader>wj", "<C-w>s") -- split window down
keymap.set("n", "<leader>we", "<C-w>=") -- make split windows equal width & height
keymap.set("n", "<leader>ww", ":close<CR>") -- close current split window
keymap.set("n", "<leader>=", "<C-w>>") -- increment window width
keymap.set("n", "<leader>-", "<C-w><") -- decrement window width
-- vim-maximizer
keymap.set("n", "<leader>wm", ":MaximizerToggle<CR>")
-- Tabs
keymap.set("n", "<leader>tn", ":tabnew<CR>") -- open new tab
keymap.set("n", "<leader>tc", ":tabclose<CR>") -- close current tab
keymap.set("n", "<leader>tl", ":tabn<CR>") --  go to next tab
keymap.set("n", "<leader>th", ":tabp< R>") --  go to previous tab

vim.g.VM_maps = {
  ["Find Under"] = "gb",
  ["Find Subword Under"] = "gb",
}
