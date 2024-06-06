return {
  "numToStr/Comment.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local comment = require("Comment")
    local os = require("app.plugins.nvim-os-persist")
    comment.setup({
      post_hook = function(ctx)
        local U = require("Comment.utils")
        if ctx.cmotion == U.cmotion.v or ctx.cmotion == U.cmotion.V then
          vim.cmd("norm! gv")
        end
      end,
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
