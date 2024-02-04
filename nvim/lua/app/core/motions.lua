--- @class Motion
--- @field keymaps table<string, string | table<OsOptions, string>>
local Motion = {}

--- @param keymap table<string, string | table<OsOptions, string>>
--- @return Motion
function Motion:setup(keymap)
  self.keymaps = keymaps
  self.__index = self
  return self
end

--- @param key string
--- @return string
function Motion:get(key)
  local maps = self.keymaps[key]
  if type(maps) == "string" then
    return maps
  end
  if require("app.core.os"):is_windows() then
    return maps.windows
  end
  return maps.default
end

local motion = Motion:setup({
  lsp_hover = {
    default = "<C-<>",
    windows = "^hov",
  },
  lsp_diagnostic = {
    default = "<C->>",
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
