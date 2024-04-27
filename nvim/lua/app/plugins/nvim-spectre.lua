return {
  "nvim-pack/nvim-spectre",
  event = "VeryLazy",
  config = function()
    local spectre = require("spectre")
    local keymap = vim.keymap
    keymap.set("n", "<leader>ss", spectre.toggle)
    keymap.set("n", "<leader>sf", function()
      spectre.open_visual({ select_word = true })
    end)
  end,
}
