local function is_terminals_open()
  return require("toggleterm.ui").find_open_windows()
end

local is_windows = require("nvim-os-persist").is_windows
if is_windows then
  vim.opt.shell = "powershell"
  vim.opt.shellcmdflag =
    "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;"
  vim.opt.shellredir = "-RedirectStandardOutput %s -NoNewWindow -Wait"
  vim.opt.shellpipe = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode"
  vim.opt.shellquote = ""
  vim.opt.shellxquote = ""
end

return {
  "akinsho/toggleterm.nvim",
  event = "VeryLazy",
  config = function()
    local toggleterm = require("toggleterm")
    toggleterm.setup({
      open_mapping = "<leader>t",
      direction = "float",
      start_in_insert = false,
      hide_numbers = false,
      insert_mappings = false,
      terminal_mappings = false,
    })

    vim.keymap.set("t", "<C-q>", "<cmd>ToggleTerm<cr>", { silent = true })
  end,
  is_terminals_open = is_terminals_open,
}
