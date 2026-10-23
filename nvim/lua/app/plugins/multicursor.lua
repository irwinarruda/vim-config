local function mc()
  return require("multicursor-nvim")
end

-- Keys mirror vim-visual-multi's defaults
return {
  "jake-stewart/multicursor.nvim",
  branch = "1.0",
  keys = {
    {
      "<C-n>",
      function()
        mc().matchAddCursor(1)
      end,
      mode = { "n", "x" },
      desc = "Add cursor at next match",
    },
    {
      "<C-Down>",
      function()
        mc().lineAddCursor(1)
      end,
      mode = { "n", "x" },
      desc = "Add cursor below",
    },
    {
      "<C-Up>",
      function()
        mc().lineAddCursor(-1)
      end,
      mode = { "n", "x" },
      desc = "Add cursor above",
    },
    {
      "\\\\A",
      function()
        mc().matchAllAddCursors()
      end,
      mode = { "n", "x" },
      desc = "Add cursors at all matches",
    },
    {
      "<C-LeftMouse>",
      function()
        mc().handleMouse()
      end,
    },
  },
  config = function()
    local multicursor = mc()
    multicursor.setup()

    -- Only active while there are multiple cursors
    multicursor.addKeymapLayer(function(layer)
      layer({ "n", "x" }, "n", function()
        multicursor.matchAddCursor(1)
      end)
      layer({ "n", "x" }, "N", function()
        multicursor.matchAddCursor(-1)
      end)
      layer({ "n", "x" }, "q", function()
        multicursor.matchSkipCursor(1)
      end)
      layer({ "n", "x" }, "Q", multicursor.deleteCursor)
      layer("n", "<Esc>", multicursor.clearCursors)
    end)
  end,
}
