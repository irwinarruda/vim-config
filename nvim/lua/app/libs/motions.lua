--- @class Motion
--- @field keymaps table<string, string | table<OsOptions, string>>
local Motion = {}

--- @param keymap table<string, string | table<OsOptions, string>>
--- @return Motion
function Motion:setup(keymap)
  self.keymaps = keymap
  return self
end

--- @param key string
--- @return string
function Motion:get(key)
  local maps = self.keymaps[key]
  if type(maps) == "string" then
    return maps
  end
  if require("app.libs.os"):is_windows() then
    return maps.windows
  end
  return maps.default
end

local motion = Motion:setup({
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
})

return motion
