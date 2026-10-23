vim.g.mapleader = " "

local keymap = vim.keymap

require("app.core.tailwind-lsp").setup()
require("app.core.typescript-lsp").setup()

-- Terminal
keymap.set("t", "<ESC>", "<C-\\><C-n>", { silent = true })
-- Lines
keymap.set("n", "<leader>o", "o<Esc>k_")
keymap.set("n", "<leader>O", "O<Esc>j_")
keymap.set("n", "<C-o>", "<C-o>zz")
keymap.set("n", "<C-i>", "<C-i>zz")
keymap.set("n", "G", "Gzz")
-- Remove highlight
keymap.set("n", "<leader><Esc>", "<cmd>nohlsearch<CR>", { silent = true })
-- Increment and decrement
keymap.set("n", "<leader>=", "<C-a>")
keymap.set("n", "<leader>-", "<C-x>")
-- Removes buffer when paste
keymap.set("n", "x", '"_x')
keymap.set({ "n", "x" }, "<leader>p", '"_dP')
keymap.set({ "n", "x" }, "<leader>d", '"_d')
keymap.set("x", "<leader>c", '"_c')
keymap.set("n", "<leader>s", '"_s')
-- Move blocks of code
keymap.set("x", "<", "<gv")
keymap.set("x", ">", ">gv")
keymap.set("x", "J", ":m '>+1<CR>gv=gv", { silent = true })
keymap.set("x", "K", ":m '<-2<CR>gv=gv", { silent = true })
keymap.set("x", "y", "y`]")
-- Ctrl D with cursor in the middle
keymap.set("n", "<C-d>", "<C-d>zz")
keymap.set("n", "<C-u>", "<C-u>zz")
keymap.set("n", "n", "nzzzv")
keymap.set("n", "N", "Nzzzv")
-- Split windows
keymap.set("n", "<leader>wl", "<C-w>v") -- split window right
keymap.set("n", "<leader>wj", "<C-w>s") -- split window down
keymap.set("n", "<leader>we", "<C-w>=") -- make split windows equal width & height
keymap.set("n", "<leader>ww", "<cmd>close<CR>") -- close current split window

-- NvimTree sits on the left, so its resize direction is flipped to keep
-- <M-h>/<M-l> moving the split edge left/right.
local function resize_width(normal, tree)
  return function()
    vim.cmd("wincmd 5" .. (vim.bo.filetype == "NvimTree" and tree or normal))
  end
end
keymap.set("n", "<M-h>", resize_width(">", "<"))
keymap.set("n", "<M-l>", resize_width("<", ">"))
keymap.set("n", "<M-k>", "<C-w>3+") -- increment window height
keymap.set("n", "<M-j>", "<C-w>3-") -- decrement window height

keymap.set("n", "<leader>j", "<cmd>cnext<CR>zz", { desc = "Forward qfixlist" })
keymap.set("n", "<leader>k", "<cmd>cprev<CR>zz", { desc = "Backward qfixlist" })

-- Paste actions
keymap.set("n", "<leader><leader>p", "p=`[v`]=")

keymap.set("n", "<leader><leader>w", "<cmd>noa w<CR>", { desc = "Write without autocommands" })
keymap.set("n", "<leader>u", function()
  vim.cmd.packadd("nvim.undotree") -- built-in since Neovim 0.12
  require("undotree").open()
end, { desc = "Toggle undo tree" })
keymap.set("n", "<leader>at", function()
  require("app.core.tailwind-lsp").apply_buffer_suggestions()
end, { desc = "Apply Tailwind LSP fixes in current buffer" })

local function close_other_buffers()
  local current = vim.api.nvim_get_current_buf()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if
      buf ~= current
      and vim.bo[buf].buflisted
      and vim.bo[buf].filetype ~= "NvimTree"
      and vim.bo[buf].buftype ~= "terminal"
    then
      pcall(vim.api.nvim_buf_delete, buf, {})
    end
  end
end

keymap.set("n", "<leader><leader>b", close_other_buffers, { desc = "Close all buffers except current and NvimTree" })

keymap.set("n", "<leader><leader>r", function()
  close_other_buffers()
  for _, client in ipairs(vim.lsp.get_clients()) do
    client:stop()
  end
  vim.defer_fn(function()
    vim.cmd("e!")
  end, 500)
  vim.cmd("e!")
end, { desc = "Reload LSP and buffers" })
-- Debug
keymap.set("n", "<leader><leader>s", function()
  local path = vim.fn.stdpath("state") .. "/swap"
  vim.fn.delete(path, "rf")
  vim.cmd("messages clear")
  print("Swap files deleted.")
  vim.fn.mkdir(path, "p")
end)

vim.api.nvim_create_user_command("W", "write", {})

local function open_qf_item()
  local qf_info = vim.fn.getqflist({ idx = 0, items = true })
  local qf_item = qf_info.items[qf_info.idx]

  if qf_item and qf_item.bufnr then
    vim.cmd("buffer " .. qf_item.bufnr)
    vim.cmd("wincmd p")
  end
end

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("QuickfixKeymaps", { clear = true }),
  pattern = "qf",
  callback = function(event)
    local opts = { silent = true, buf = event.buf }
    keymap.set("n", "J", function()
      if pcall(vim.cmd.cnext) then
        open_qf_item()
      end
    end, opts)
    keymap.set("n", "K", function()
      if pcall(vim.cmd.cprev) then
        open_qf_item()
      end
    end, opts)
    keymap.set("n", "dd", function()
      local qf_list = vim.fn.getqflist()
      table.remove(qf_list, vim.fn.line("."))
      vim.fn.setqflist(qf_list, "r")
    end, { buf = event.buf, desc = "Remove current item from quickfix list" })
  end,
})
