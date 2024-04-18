local harpoon_select = function(index)
  return function()
    if require("app.plugins.toggleterm").is_terminals_open() then
      return
    end
    local harpoon = require("harpoon")
    harpoon:list():select(index)
    vim.cmd("normal! zz")
  end
end

return {
  "ThePrimeagen/harpoon",
  event = "VeryLazy",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local harpoon = require("harpoon")
    harpoon:setup()

    local keymap = vim.keymap
    keymap.set("n", "<leader>a", function()
      harpoon:list():add()
    end)
    keymap.set("n", "<leader><Tab>", function()
      harpoon.ui:toggle_quick_menu(harpoon:list())
    end)

    keymap.set("n", "<leader>1", harpoon_select(1))
    keymap.set("n", "<leader>2", harpoon_select(2))
    keymap.set("n", "<leader>3", harpoon_select(3))
    keymap.set("n", "<leader>4", harpoon_select(4))
    keymap.set("n", "<leader>5", harpoon_select(5))
    keymap.set("n", "<leader>6", harpoon_select(6))
  end,
}
