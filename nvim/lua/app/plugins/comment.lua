return {
  "numToStr/Comment.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local comment = require("Comment")
    local os = require("app.plugins.nvim-os-persist")
    comment.setup({
      toggler = {
        line = os.motion("comment"),
        block = os.motion("block_comment"),
      },
      opleader = {
        line = os.motion("comment"),
        block = os.motion("block_comment"),
      },
    })
  end,
}
