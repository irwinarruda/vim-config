return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  keys = {
    {
      "<leader>gb",
      function()
        require("gitsigns").toggle_current_line_blame()
      end,
      desc = "Toggle current line blame",
    },
  },
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
        local opts = { buf = bufnr }

        -- In diff mode fall back to vim's own change motions
        keymap.set("n", "[g", function()
          if vim.wo.diff then
            vim.cmd.normal({ "]czz", bang = true })
          else
            gitsigns.nav_hunk("next")
            vim.cmd.normal("zz")
          end
        end, opts)
        keymap.set("n", "]g", function()
          if vim.wo.diff then
            vim.cmd.normal({ "[czz", bang = true })
          else
            gitsigns.nav_hunk("prev")
            vim.cmd.normal("zz")
          end
        end, opts)
        keymap.set("n", "<leader>gr", gitsigns.reset_hunk, opts)
        keymap.set("n", "<leader>ga", gitsigns.reset_buffer, opts)
        -- Calling twice opens the preview, then jumps into it
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
        keymap.set("n", "<leader>gf", gitsigns.diffthis, opts)
      end,
    })
    vim.api.nvim_set_hl(0, "GitSignsCurrentLineBlame", { link = "DraculaFg" })
  end,
}
