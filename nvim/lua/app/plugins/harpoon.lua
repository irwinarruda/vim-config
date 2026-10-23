-- A floating toggleterm sits on top of the editor; don't swap the buffer underneath it
local function terminal_is_open()
  local ok, ui = pcall(require, "toggleterm.ui")
  return ok and ui.find_open_windows()
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

    for index = 1, 9 do
      keymap.set("n", "<leader>" .. index, function()
        if not terminal_is_open() then
          harpoon:list():select(index)
        end
      end)
    end
  end,
}
