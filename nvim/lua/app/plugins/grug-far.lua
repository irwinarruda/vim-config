local INSTANCE = "far"

return {
  "MagicDuck/grug-far.nvim",
  cmd = "GrugFar",
  keys = {
    {
      "<leader>ss",
      function()
        require("grug-far").toggle_instance({ instanceName = INSTANCE, staticTitle = "Find and Replace" })
      end,
      desc = "Toggle find and replace",
    },
    {
      "<leader>sf",
      function()
        local grug_far = require("grug-far")
        local search = vim.fn.expand("<cword>")
        if grug_far.has_instance(INSTANCE) then
          -- Reuse the open panel; a second one with the same name is an error
          grug_far.get_instance(INSTANCE):update_input_values({ search = search }, false)
          return
        end
        grug_far.open({ instanceName = INSTANCE, staticTitle = "Find and Replace", prefills = { search = search } })
      end,
      desc = "Find and replace word under cursor",
    },
    {
      "<leader>sr",
      function()
        local grug_far = require("grug-far")
        if grug_far.has_instance(INSTANCE) then
          grug_far.get_instance(INSTANCE):replace()
        end
      end,
      desc = "Run replace",
    },
  },
  opts = {},
}
