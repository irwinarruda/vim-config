local s1, comment = pcall(require, "Comment")
if not s1 then
  return
end

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
