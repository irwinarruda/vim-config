local M = {}

M.valid_names = { "tsc", "vtsls", "typescript-tools" }
M.default = "tsc"

local function get_filepath()
  return vim.fn.stdpath("data") .. "/typescript_lsp.txt"
end

--- Reads both the LSP name and restore flag from the file.
--- Line 1: LSP name, Line 2: "restore" (if pending)
local function read_file()
  local f = io.open(get_filepath(), "r")
  if not f then
    return M.default, false
  end
  local name = f:read("*l")
  local restore_line = f:read("*l")
  f:close()
  name = name and vim.trim(name)
  if not vim.tbl_contains(M.valid_names, name) then
    name = M.default
  end
  local pending = restore_line ~= nil and vim.trim(restore_line) == "restore"
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
  return (read_file())
end

function M.set(name)
  write_file(name, false)
end

function M.set_pending_restore()
  write_file(M.get(), true)
end

function M.consume_pending_restore()
  local name, pending = read_file()
  if pending then
    write_file(name, false)
  end
  return pending
end

function M.setup()
  vim.api.nvim_create_user_command("LspChange", function(opts)
    local name = opts.args
    if not vim.tbl_contains(M.valid_names, name) then
      vim.notify("Invalid LSP: " .. name .. ". Valid: " .. table.concat(M.valid_names, ", "), vim.log.levels.ERROR)
      return
    end
    if M.get() == name then
      vim.notify("TypeScript LSP is already set to " .. name, vim.log.levels.INFO)
      return
    end
    M.set(name)
    M.set_pending_restore()
    -- Save session via persistence.nvim, save all buffers, then quit
    require("persistence").save()
    vim.cmd("silent! wall")
    vim.notify("TypeScript LSP changed to " .. name .. ". Run `nvim .` to restore your session.", vim.log.levels.INFO)
    vim.cmd("qa!")
  end, {
    nargs = 1,
    complete = function()
      return M.valid_names
    end,
    desc = "Change TypeScript LSP and restart Neovim",
  })
end

return M
