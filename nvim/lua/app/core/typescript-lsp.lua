local M = {}

M.valid_names = { "vtsls", "tsgo", "typescript-tools" }
M.default = "tsgo"

local function get_filepath()
  return vim.fn.stdpath("data") .. "/typescript_lsp.txt"
end

--- Reads both the LSP name and restore flag from the file.
--- Line 1: LSP name, Line 2: "restore" (if pending)
local function read_file()
  local filepath = get_filepath()
  local f = io.open(filepath, "r")
  if not f then
    return M.default, false
  end
  local name = f:read("*l")
  local restore_line = f:read("*l")
  f:close()
  if name then
    name = vim.trim(name)
    if not vim.tbl_contains(M.valid_names, name) then
      name = M.default
    end
  else
    name = M.default
  end
  local pending = restore_line and vim.trim(restore_line) == "restore"
  return name, pending
end

local function write_file(name, restore)
  local filepath = get_filepath()
  local f = io.open(filepath, "w")
  if not f then
    vim.notify("Failed to write TypeScript LSP choice to " .. filepath, vim.log.levels.ERROR)
    return
  end
  f:write(name .. "\n")
  if restore then
    f:write("restore\n")
  end
  f:close()
end

function M.get()
  local name, _ = read_file()
  return name
end

function M.set(name)
  write_file(name, false)
end

function M.set_pending_restore()
  local name, _ = read_file()
  write_file(name, true)
end

function M.consume_pending_restore()
  local name, pending = read_file()
  if pending then
    write_file(name, false)
  end
  return pending
end

return M
