local s1, nvimtree = pcall(require, "nvim-tree")
local s2, nvimtreeapi = pcall(require, "nvim-tree.api")

if not s1 or not s2 then
  return
end

vim.g.loaded = 1
vim.g.loaded_netrwPlugin = 1
nvimtree.setup({
  view = {
    preserve_window_proportions = false,
  },
  actions = {
    open_file = {
      resize_window = true,
    },
  },
  git = {
    ignore = false,
  },
})

vim.keymap.set("n", "<leader>e", function()
  nvimtreeapi.tree.toggle({ find_file = true, focus = false })
end)

vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
  desc = "Find file on open",
  pattern = "*",
  callback = function()
    local s, nvim_tree = pcall(require, "nvim-tree.api")
    if s then
      nvim_tree.tree.find_file({ open = false, focus = false })
    end
  end,
})
