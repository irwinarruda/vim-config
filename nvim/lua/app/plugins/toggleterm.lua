local s1, toggleterm = pcall(require, "toggleterm")
if not s1 then
  return
end

toggleterm.setup({
  open_mapping = "<leader>t",
  direction = "tab",
})

vim.keymap.set("n", "<leader>'", "<CMD>tabn<CR>")
