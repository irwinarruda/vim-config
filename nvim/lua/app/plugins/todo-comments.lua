return {
  "folke/todo-comments.nvim",
  event = "VeryLazy",
  config = function()
    local todo_comments = require("todo-comments")
    todo_comments.setup()
    vim.keymap.set("n", "<leader>fc", "<CMD>TodoTelescope<CR>")
  end,
}
