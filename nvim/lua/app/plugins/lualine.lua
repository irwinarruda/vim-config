local s1, lualine = pcall(require, "lualine")
local s2, lualine_dracula = pcall(require, "lualine.themes.dracula")

if not s1 or not s2 then
  return
end

lualine.setup({
  options = {
    theme = lualine_dracula,
  },
})
