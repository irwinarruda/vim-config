return {
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local gitsigns = require("gitsigns")
      gitsigns.setup({
        current_line_blame = false,
        current_line_blame_opts = {
          virt_text = true,
          virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
          delay = 350,
          ignore_whitespace = false,
          virt_text_priority = 100,
        },
        on_attach = function(bufnr)
          local keymap = vim.keymap
          local opts = { buffer = bufnr, remap = false }
          keymap.set("n", "<leader>gr", gitsigns.reset_hunk, opts)
          keymap.set("n", "<leader>gp", function()
            gitsigns.preview_hunk()
            gitsigns.preview_hunk()
          end, opts)
          keymap.set("n", "<leader>gg", function()
            gitsigns.blame_line({ full = true })
            vim.defer_fn(function()
              gitsigns.blame_line({ full = true })
            end, 50)
          end, opts)
          keymap.set("n", "<leader>gb", gitsigns.toggle_current_line_blame, opts)
          keymap.set("n", "<leader>gf", gitsigns.diffthis, opts)
        end,
      })
      vim.cmd([[
      hi! link GitSignsCurrentLineBlame DraculaFg
      ]])
    end,
  },
  {
    "github/copilot.vim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local keymap = vim.keymap
      keymap.set("n", "<leader>gce", ":Copilot enable<CR>")
      keymap.set("n", "<leader>gcd", ":Copilot disable<CR>")
    end,
  },
}
