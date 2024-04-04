local s1, comment = pcall(require, "Comment")
if not s1 then
  return
end

local os = require("nvim-os-persist")
comment.setup({
  toggler = {
    line = os.keymap("comment"),
    block = os.keymap("block_comment"),
  },
  opleader = {
    line = os.keymap("comment"),
    block = os.keymap("block_comment"),
  },
})
