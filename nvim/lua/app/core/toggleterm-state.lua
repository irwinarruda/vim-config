local M = {}

function M.is_terminals_open()
  local ok, ui = pcall(require, "toggleterm.ui")
  if not ok then
    return false
  end

  local windows = ui.find_open_windows()
  if type(windows) == "table" then
    return #windows > 0
  end

  return windows and true or false
end

return M
