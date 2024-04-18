return {
  "stevearc/dressing.nvim",
  event = "VeryLazy",
  config = function()
    local dressing = require("dressing")
    dressing.setup({
      select = {
        enabled = false,
      },
    })
  end,
}
