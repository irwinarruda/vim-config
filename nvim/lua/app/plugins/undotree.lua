return {
  "mbbill/undotree",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local keymap = vim.keymap
    keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)
  end,
}
