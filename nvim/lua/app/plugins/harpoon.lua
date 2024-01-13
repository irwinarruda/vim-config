local s1, harpoon = pcall(require, "harpoon")
if not s1 then
  return
end

harpoon:setup()

local keymap = vim.keymap
keymap.set("n", "<leader>a", function()
  harpoon:list():append()
end)
keymap.set("n", "<leader><Tab>", function()
  harpoon.ui:toggle_quick_menu(harpoon:list())
end)

keymap.set("n", "<leader>1", function()
  harpoon:list():select(1)
end)
keymap.set("n", "<leader>2", function()
  harpoon:list():select(2)
end)
keymap.set("n", "<leader>3", function()
  harpoon:list():select(3)
end)
keymap.set("n", "<leader>4", function()
  harpoon:list():select(4)
end)
keymap.set("n", "<leader>5", function()
  harpoon:list():select(5)
end)
keymap.set("n", "<leader>6", function()
  harpoon:list():select(6)
end)
