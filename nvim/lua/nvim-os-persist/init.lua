local Motion = require("nvim-os-persist.motions")
local utils = require("nvim-os-persist.utils")

--- @class OSPersistConfig
--- @field keymaps table<string, string | table<OsOptions, string>>
--- @field private motion Motions?
local config = {
  keymaps = {},
  motion = nil,
}

local M = {}

--- @param opts OSPersistConfig
M.setup = function(opts)
  config = vim.tbl_extend("force", config, opts)
  config.motion = Motion:create(config.keymaps)
end

--- @param key string
--- @return string
M.motion = function(key)
  return config.motion:get(key)
end

--- @return boolean
M.is_windows = function()
  return utils.Os:is_windows()
end

return M
