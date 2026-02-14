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
keymap.set("v", "<", "<gv")
keymap.set("v", "J", ":m '>+1<CR>gv=gv", { silent = true })
keymap.set("v", "K", ":m '<-2<CR>gv=gv", { silent = true })
keymap.set("v", ">", ">gv")
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
keymap.set("n", "<leader>j", "<cmd>cnext<CR>zz", { desc = "Forward qfixlist" })
keymap.set("n", "<leader>k", "<cmd>cprev<CR>zz", { desc = "Backward qfixlist" })

-- Paste actions
keymap.set("n", "<leader><leader>p", "p=`[v`]=")

keymap.set("n", "<leader><leader>w", "<cmd>noa w<CR>", { desc = "Write without autocommands" })

keymap.set("n", "<leader><leader>b", function()
  local current = vim.api.nvim_get_current_buf()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if buf ~= current and vim.api.nvim_buf_is_loaded(buf) then
      local ft = vim.bo[buf].filetype
      if ft ~= "NvimTree" then
        vim.api.nvim_buf_delete(buf, {})
      end
    end
  end
end, { desc = "Close all buffers except current and NvimTree" })
-- Debug
keymap.set("n", "<leader><leader>s", function()
  local path = vim.fn.stdpath("state") .. "/swap"
  vim.fn.delete(path, "rf")
  vim.cmd("messages clear")
  vim.cmd("lua print('Swap files deleted.')")
  vim.fn.mkdir(path, "p")
end)

vim.api.nvim_create_user_command("W", "write", {})

vim.api.nvim_create_user_command("LspChange", function(opts)
  local ts_lsp = require("app.core.typescript-lsp")
  local name = opts.args
  if not vim.tbl_contains(ts_lsp.valid_names, name) then
    vim.notify("Invalid LSP: " .. name .. ". Valid: " .. table.concat(ts_lsp.valid_names, ", "), vim.log.levels.ERROR)
    return
  end
  local current = ts_lsp.get()
  if current == name then
    vim.notify("TypeScript LSP is already set to " .. name, vim.log.levels.INFO)
    return
  end
  ts_lsp.set(name)
  ts_lsp.set_pending_restore()
  -- Save session via persistence.nvim, save all buffers, then quit
  require("persistence").save()
  vim.cmd("silent! wall")
  vim.notify("TypeScript LSP changed to " .. name .. ". Run `nvim .` to restore your session.", vim.log.levels.INFO)
  vim.cmd("qa!")
end, {
  nargs = 1,
  complete = function()
    return require("app.core.typescript-lsp").valid_names
  end,
  desc = "Change TypeScript LSP and restart Neovim",
})

local function open_qf_item()
  local qf_info = vim.fn.getqflist({ idx = 0, items = true })
  local idx = qf_info.idx
  local qf_item = qf_info.items[idx]

  if qf_item and qf_item.bufnr then
    vim.cmd("buffer " .. qf_item.bufnr)
    vim.cmd("wincmd p")
  end
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = "qf",
  callback = function()
    local opts = { noremap = true, silent = true, buffer = true }
    vim.keymap.set("n", "J", function()
      ---@diagnostic disable-next-line: param-type-mismatch
      if pcall(vim.cmd, "cnext") then
        open_qf_item()
      end
    end, opts)
    vim.keymap.set("n", "K", function()
      ---@diagnostic disable-next-line: param-type-mismatch
      if pcall(vim.cmd, "cprev") then
        open_qf_item()
      end
    end, opts)
    vim.keymap.set("n", "dd", function()
      local qf_list = vim.fn.getqflist()
      local cursor_line = vim.fn.line(".")
      table.remove(qf_list, cursor_line)
      vim.fn.setqflist(qf_list, "r")
    end, { buffer = true, desc = "Remove current item from quickfix list" })
  end,
})
