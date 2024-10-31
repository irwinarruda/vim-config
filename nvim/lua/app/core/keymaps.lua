vim.g.mapleader = " "

local keymap = vim.keymap

-- Terminal
keymap.set("t", "<ESC>", "<C-\\><C-n>", { silent = true })
-- Lines
keymap.set("n", "<leader>o", "o<Esc>k_")
keymap.set("n", "<leader>O", "O<Esc>j_")
keymap.set("n", "<C-o>", "<C-o>zz", { noremap = true })
keymap.set("n", "<C-i>", "<C-i>zz", { noremap = true })
keymap.set("n", "G", "Gzz", { noremap = true })
-- Remove highlight
keymap.set("n", "<leader><Esc>", ":nohlsearch<CR>", { silent = true })
-- Increment and decrement
keymap.set("n", "<leader>=", "<C-a>")
keymap.set("n", "<leader>-", "<C-x>")
-- Removes buffer when paste
keymap.set("n", "x", '"_x')
keymap.set("n", "<leader>p", '"_dP', { noremap = true })
keymap.set("v", "<leader>p", '"_dP', { noremap = true })
keymap.set("n", "<leader>d", '"_d', { noremap = true })
keymap.set("v", "<leader>d", '"_d', { noremap = true })
keymap.set("v", "<leader>c", '"_c', { noremap = true })
keymap.set("n", "<leader>s", '"_s', { noremap = true })
-- Move blocks of code
keymap.set("v", "J", ":m '>+1<CR><CR>gv=gv", { silent = true })
keymap.set("v", "K", ":m '<-2<CR><CR>gv=gv", { silent = true })
keymap.set("v", ">", ">gv")
keymap.set("v", "<", "<gv")
keymap.set("v", "y", "y`]", { noremap = true })
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

keymap.set("n", "<M-h>", function()
  local bufname = vim.api.nvim_buf_get_name(0)
  if bufname:match("NvimTree_1") then
    vim.cmd("wincmd 5<")
  else
    vim.cmd("wincmd 5>")
  end
end) -- increment window width
keymap.set("n", "<M-l>", function()
  local bufname = vim.api.nvim_buf_get_name(0)
  if bufname:match("NvimTree_1") then
    vim.cmd("wincmd 5>")
  else
    vim.cmd("wincmd 5<")
  end
end) -- decrement window width
keymap.set("n", "<M-k>", "<C-w>3+", { noremap = true }) -- increment window height
keymap.set("n", "<M-j>", "<C-w>3-", { noremap = true }) -- decrement window height
-- vim-maximizer
keymap.set("n", "<leader>wm", ":MaximizerToggle<CR>")

-- Debug
keymap.set("n", "<leader><leader>w", "<cmd>w<cr><cmd>source %<cr><cmd>messages clear<cr>")
keymap.set("n", "<leader><leader>s", function()
  local path = vim.fn.stdpath("state") .. "/swap"
  vim.fn.delete(path, "rf")
  vim.cmd("messages clear")
  vim.cmd("lua print('Swap files deleted.')")
  vim.fn.mkdir(path, "p")
end)

vim.api.nvim_create_user_command("W", "write", {})

vim.g.VM_maps = {
  ["Find Under"] = "gb",
  ["Find Subword Under"] = "gb",
}
