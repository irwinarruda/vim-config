local s1, comment = pcall(require, "Comment")
if not s1 then
  return
end

local motions = require("app.core.motions")
comment.setup({
  toggler = {
    line = motions:get("comment"),
    block = motions:get("block_comment"),
  },
  opleader = {
    line = motions:get("comment"),
    block = motions:get("block_comment"),
  }
})
