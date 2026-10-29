-- Opened through <leader>fg, see telescope.lua
return {
  "esmuellert/codediff.nvim",
  cmd = "CodeDiff",
  opts = {
    keymaps = {
      view = {
        -- [ goes forward like [g and [d
        next_hunk = { "]c", "<leader>[" },
        prev_hunk = { "[c", "<leader>]" },
      },
    },
  },
}
