local shown_once_messages = {}

--- Route filter that lets the first message containing `pattern` through and skips the rest.
local function skip_after_first(pattern)
  return function(message)
    if not message:content():find(pattern, 1, true) then
      return false
    end
    if shown_once_messages[pattern] then
      return true
    end
    shown_once_messages[pattern] = true
    return false
  end
end

return {
  "folke/noice.nvim",
  event = "VeryLazy",
  dependencies = {
    "MunifTanjim/nui.nvim",
    {
      "rcarriga/nvim-notify",
      opts = {
        background_colour = "#0B0D0F",
        merge_duplicates = true,
      },
    },
  },
  keys = {
    { "<leader><leader>n", "<cmd>NoiceDismiss<CR>" },
  },
  opts = {
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
      },
      hover = {
        silent = true,
        view = "hover",
      },
      signature = {
        enabled = false,
      },
    },
    presets = {
      long_message_to_split = true, -- long messages will be sent to a split
      lsp_doc_border = true, -- add a border to hover docs and signature help
    },
  },
}
