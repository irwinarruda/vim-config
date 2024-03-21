local s1, template_string = pcall(require, "template-string")
if not s1 then
  return
end

template_string.setup()
