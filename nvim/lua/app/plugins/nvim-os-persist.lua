--- @param key string
--- @return string
local function motion(key)
  local os_persist = require("nvim-os-persist")
  return os_persist.motion(key)
end

return {
  dir = vim.fn.stdpath("config") .. "/lua/nvim-os-persist",
  dev = true,
  priority = 1000,
  config = function()
    local os_persist = require("nvim-os-persist")
    os_persist.setup({
      keymaps = {
        lsp_hover = {
          default = "<C-S-,>",
          windows = "^hov",
        },
        lsp_hover_diagnostic = {
          default = "<C-S-.>",
          windows = "^hdi",
        },
        lsp_diagnostic = {
          default = "<leader>.",
          windows = "^dia",
        },
        lsp_code_action = {
          default = "<C-.>",
          windows = "^act",
        },
        lsp_definitions = {
          default = "<C-,>",
          windows = "^def",
        },
        lsp_implementation = {
          default = "<C-n>",
          windows = "^imp",
        },
        lsp_references = {
          default = "<C-m>",
          windows = "^ref",
        },
        lsp_rename = "<F2>",
        lsp_goto_next = "[d",
        lsp_goto_prev = "]d",
        lsp_ts_rename_file = "<leader>rr",
        lsp_ts_remove_imports = "<leader>rc",
        lsp_ts_sort_imports = "<leader>ri",
        lsp_ts_select_version = "<leader>rt",
        cmp_complete = {
          default = "<C-Space>",
          windows = "^esp",
        },
        comment = {
          default = "<C-;>",
          windows = "^com",
        },
        block_comment = {
          default = "<C-c><C-;>",
          windows = "^bco",
        },
      },
    })
  end,
  motion = motion,
}
