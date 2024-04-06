local s1, os_persist = pcall(require, "nvim-os-persist")
if not s1 then
  return
end

os_persist.setup({
  keymaps = {
    lsp_hover = {
      default = "<C-<>",
      windows = "^hov",
    },
    lsp_hover_diagnostic = {
      default = "<C->>",
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
    lsp_references = {
      default = "<C-m>",
      windows = "^ref",
    },
    lsp_rename = "<F2>",
    lsp_workspace_symbol = "<leader>vws",
    lsp_goto_next = "[d",
    lsp_goto_prev = "]d",
    lsp_signature_help = "<C-h>",
    lsp_ts_rename_file = "<leader>rr",
    lsp_ts_remove_imports = "<leader>rc",
    lsp_ts_sort_imports = "<leader>ri",
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

--- @param key string
--- @return string
local function motion(key)
  return os_persist.motion(key)
end

return {
  motion = motion,
}
