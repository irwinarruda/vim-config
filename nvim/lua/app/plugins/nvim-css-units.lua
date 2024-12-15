return {
  dir = vim.fn.stdpath("config") .. "/lua/nvim-css-units",
  dev = true,
  priority = 1000,
  config = function()
    local css_units = require("nvim-css-units")
    css_units.setup({
      base_px = 16,
      virt_text = {
        enabled = true,
        debounce = 350,
      },
    })

    local keymap = vim.keymap

    keymap.set("n", "<leader>ar", css_units.toggle_unit)
    keymap.set("i", "<C-a>", css_units.toggle_unit)
    keymap.set("n", "<leader>ac", css_units.copy_to_rem)
    keymap.set("n", "<leader>aa", css_units.toggle_virt_text)
  end,
}
