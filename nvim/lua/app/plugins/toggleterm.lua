local s1, toggleterm = pcall(require, "toggleterm")
if not s1 then
  return
end

toggleterm.setup({
  open_mapping = "<leader>t",
  direction = "float",
  start_in_insert = true,
  hide_numbers = false,
  insert_mappings = false,
  terminal_mappings = false,
})

vim.keymap.set("t", "<C-q>", "<cmd>ToggleTerm<cr>", { silent = true })
