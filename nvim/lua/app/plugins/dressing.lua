local s1, dressing = pcall(require, "dressing")
if not s1 then
  return
end

dressing.setup({
  select = {
    enabled = false,
  },
})
