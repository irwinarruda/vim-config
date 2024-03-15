local s1, indentscope = pcall(require, "mini.indentscope")
if not s1 then
  return
end

indentscope.setup()
