return {
  "numToStr/Comment.nvim",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "JoosepAlviste/nvim-ts-context-commentstring",
    "nvim-os-persist",
  },
  config = function()
    local comment = require("Comment")
    local os = require("nvim-os-persist")
    comment.setup({
      pre_hook = function(ctx)
        local commentstring = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook()(ctx)
        if commentstring ~= nil then
          return commentstring
        end
        return vim.bo.commentstring ~= "" and vim.bo.commentstring or "# %s"
      end,
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
