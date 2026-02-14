return {
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    config = function()
      require("notify").setup({
        background_colour = "#0B0D0F",
        merge_duplicates = true,
      })

      local shown_once_messages = {}
      local function skip_after_first(pattern)
        return function(message)
          local content = ""
          if message._lines and message._lines[1] and message._lines[1]._texts and message._lines[1]._texts[1] then
            content = message._lines[1]._texts[1]._content or ""
          end
          if content:find(pattern, 1, true) then
            if shown_once_messages[pattern] then
              return true
            end
            shown_once_messages[pattern] = true
          end
          return false
        end
      end

      require("noice").setup({
        routes = {
          {
            filter = {
              event = "msg_show",
              kind = "",
              find = "gravado",
            },
            opts = { skip = true },
          },
          {
            filter = {
              cond = skip_after_first("Request textDocument/diagnostic failed"),
            },
            opts = { skip = true },
          },
        },
        lsp = {
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = true,
          },
          hover = {
            silent = true,
            view = "hover",
          },
          signature = {
            enabled = false,
          },
        },
        messages = {
          enabled = true, -- enables the Noice messages UI
          view = "notify", -- default view for messages
          view_error = "notify", -- view for errors
          view_warn = "notify", -- view for warnings
          view_history = "messages", -- view for :messages
          view_search = "virtualtext", -- view for search count messages. Set to `false` to disable
        },
        presets = {
          bottom_search = false, -- use a classic bottom cmdline for search
          command_palette = false, -- position the cmdline and popupmenu together
          long_message_to_split = true, -- long messages will be sent to a split
          inc_rename = false, -- enables an input dialog for inc-rename.nvim
          lsp_doc_border = true, -- add a border to hover docs and signature help
        },
      })
      vim.keymap.set("n", "<leader><leader>n", "<cmd>NoiceDismiss<CR>")
    end,
  },
  {
    "stevearc/dressing.nvim",
    event = "VeryLazy",
    enabled = true,
    config = function()
      local dressing = require("dressing")
      dressing.setup({
        input = {
          enabled = false,
        },
        select = {
          enabled = true,
        },
      })
    end,
  },
}
