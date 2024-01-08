local s1, comment = pcall(require, "Comment")
if not s1 then
  return
end

comment.setup({
  toggler = {
    line = "<C-;>",
    block = "<C->>",
  },
  opleader = {
    line = "<C-;>",
    block = "<C->>",
  },
})
