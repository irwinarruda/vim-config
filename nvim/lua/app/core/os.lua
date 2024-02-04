--- @alias OsOptions "default" | "windows" | "macos" | "linux"

--- @class Os
local Os = {}

--- @return boolean
function Os:is_windows()
  return vim.loop.os_uname().sysname == "Windows_NT"
end

return Os

