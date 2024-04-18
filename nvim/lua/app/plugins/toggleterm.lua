local function is_terminals_open()
  return require("toggleterm.ui").find_open_windows()
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
