return {
  "nvim-pack/nvim-spectre",
  event = "VeryLazy",
  config = function()
    local spectre = require("spectre")
    local spectre_actions = require("spectre.actions")
    spectre.setup({
      replace_engine = {
        ["sed"] = {
          cmd = "sed",
          args = {
            "-i",
            "",
            "-E",
          },
        },
      },
    })
    local keymap = vim.keymap
    keymap.set("n", "<leader>ss", spectre.toggle)
    keymap.set("n", "<leader>sf", function()
      spectre.open_visual({ select_word = true })
    end)
    keymap.set("n", "<leader>sr", spectre_actions.run_replace)
  end,
}
