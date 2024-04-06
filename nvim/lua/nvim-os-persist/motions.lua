local utils = require("nvim-os-persist.utils")

--- @class Motions
--- @field keymaps table<string, string | table<OsOptions, string>>
local Motions = {}

--- @param keymap table<string, string | table<OsOptions, string>>
--- @return Motions
function Motions:create(keymap)
  self.keymaps = keymap
  return self
end

--- @param key string
--- @return string
function Motions:get(key)
  local maps = self.keymaps[key]
  if type(maps) == "string" then
    return maps
  end
  if utils.Os:is_windows() and not vim.g.neovide then
    return maps.windows
  end
  return maps.default
end

return Motions
