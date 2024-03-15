local s1, todo_comments = pcall(require, "todo-comments")
if not s1 then
  return
end

todo_comments.setup()

vim.keymap.set("n", "<leader>fc", "<CMD>TodoTelescope<CR>")
