local M = {}

local SOURCE_ACTION_TIMEOUT_MS = 10000
local FILE_RENAME_TIMEOUT_MS = 20000
local uv = vim.uv or vim.loop

local function notify(message, level)
  vim.notify(message, level or vim.log.levels.INFO, { title = "TypeScript LSP" })
end

local function is_absolute_path(path)
  return path:sub(1, 1) == "/" or path:match("^%a:[/\\]") ~= nil
end

local function normalize_path(path)
  path = vim.fn.fnamemodify(path, ":p")

  local realpath = uv.fs_realpath(path)
  if realpath then
    return realpath
  end

  local parent = vim.fs.dirname(path)
  local real_parent = parent and uv.fs_realpath(parent)
  if real_parent then
    return vim.fs.joinpath(real_parent, vim.fn.fnamemodify(path, ":t"))
  end

  return path
end

local function code_action_provider_supports(client, kind)
  local provider = client.server_capabilities.codeActionProvider
  if provider == true then
    return true
  end
  if type(provider) ~= "table" then
    return false
  end
  if not provider.codeActionKinds then
    return true
  end

  for _, supported_kind in ipairs(provider.codeActionKinds) do
    if kind == supported_kind or vim.startswith(kind, supported_kind .. ".") then
      return true
    end
  end

  return false
end

local function get_code_action_client(bufnr, kind, client_name)
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr, name = client_name })) do
    if code_action_provider_supports(client, kind) then
      return client
    end
  end

  return nil
end

local function execute_lsp_command(client, command, bufnr)
  if type(command) ~= "table" then
    return true
  end

  if client.exec_cmd then
    local ok = pcall(client.exec_cmd, client, command, { bufnr = bufnr })
    if ok then
      return true
    end
  end

  local ok, err = pcall(vim.lsp.buf.execute_command, command)
  if not ok then
    notify("Failed to execute code action command: " .. tostring(err), vim.log.levels.ERROR)
    return false
  end

  return true
end

local function resolve_code_action(client, action, bufnr)
  if action.edit or action.command then
    return action
  end

  local provider = client.server_capabilities.codeActionProvider
  if type(provider) ~= "table" or not provider.resolveProvider then
    return action
  end

  local response = client:request_sync("codeAction/resolve", action, SOURCE_ACTION_TIMEOUT_MS, bufnr)
  if response and not response.err and response.result then
    return response.result
  end

  return action
end

function M.apply_source_action(kind, opts)
  opts = opts or {}
  local bufnr = opts.bufnr or vim.api.nvim_get_current_buf()
  local client = get_code_action_client(bufnr, kind, opts.client_name)

  if not client then
    notify("No attached TypeScript client supports " .. kind, vim.log.levels.WARN)
    return false
  end

  local params = vim.lsp.util.make_range_params(0, client.offset_encoding or "utf-16")
  params.context = {
    diagnostics = {},
    only = { kind },
  }

  local response = client:request_sync("textDocument/codeAction", params, SOURCE_ACTION_TIMEOUT_MS, bufnr)
  if not response then
    notify("Timed out requesting " .. kind, vim.log.levels.ERROR)
    return false
  end
  if response.err then
    notify("Failed to request " .. kind .. ": " .. tostring(response.err.message or response.err), vim.log.levels.ERROR)
    return false
  end

  local actions = {}
  for _, action in ipairs(response.result or {}) do
    if action.kind == kind or (action.kind and vim.startswith(action.kind, kind .. ".")) then
      table.insert(actions, action)
    end
  end

  if #actions == 0 and #(response.result or {}) == 1 then
    actions = response.result
  end

  local action = actions[1]
  if not action then
    notify("No " .. kind .. " action available", vim.log.levels.INFO)
    return false
  end
  action = resolve_code_action(client, action, bufnr)

  if action.edit then
    vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding or "utf-16")
  end

  if type(action.command) == "string" then
    return execute_lsp_command(client, action, bufnr)
  end
  if action.command then
    return execute_lsp_command(client, action.command, bufnr)
  end

  return true
end

local function file_operation_capability(client, operation)
  local workspace = client.server_capabilities.workspace
  local file_operations = workspace and workspace.fileOperations
  return file_operations and file_operations[operation]
end

local function get_file_rename_clients(bufnr, client_name)
  local clients = {}

  for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr, name = client_name })) do
    if file_operation_capability(client, "willRename") then
      table.insert(clients, client)
    end
  end

  return clients
end

local function add_uri_path(paths, uri)
  if type(uri) ~= "string" then
    return
  end

  local ok, path = pcall(vim.uri_to_fname, uri)
  if ok and path and path ~= "" then
    paths[normalize_path(path)] = true
  end
end

local function collect_workspace_edit_paths(edit)
  local paths = {}

  if edit.changes then
    for uri in pairs(edit.changes) do
      add_uri_path(paths, uri)
    end
  end

  if edit.documentChanges then
    for _, change in ipairs(edit.documentChanges) do
      if change.textDocument then
        add_uri_path(paths, change.textDocument.uri)
      end
    end
  end

  return paths
end

local function get_buffer_state(path)
  local bufnr = vim.fn.bufnr(path)
  if bufnr == -1 then
    return { loaded = false, modified = false }
  end

  local loaded = vim.api.nvim_buf_is_loaded(bufnr)
  return {
    bufnr = bufnr,
    loaded = loaded,
    modified = loaded and vim.bo[bufnr].modified or false,
  }
end

local function remember_edit_paths(states, paths, old_path, new_path)
  for path in pairs(paths) do
    if path ~= old_path and path ~= new_path and not states[path] then
      states[path] = get_buffer_state(path)
    end
  end
end

local function save_touched_buffers(states)
  local skipped = {}

  for path, state in pairs(states) do
    local bufnr = vim.fn.bufnr(path)
    if bufnr ~= -1 and vim.api.nvim_buf_is_loaded(bufnr) and vim.bo[bufnr].modified then
      if state.modified then
        table.insert(skipped, path)
      else
        local ok, err = pcall(vim.api.nvim_buf_call, bufnr, function()
          vim.cmd("silent noautocmd write")
        end)
        if not ok then
          table.insert(skipped, path .. " (" .. tostring(err) .. ")")
        elseif not state.loaded and not vim.bo[bufnr].modified then
          pcall(vim.api.nvim_buf_delete, bufnr, { force = false })
        end
      end
    end
  end

  return skipped
end

local function resolve_new_path(input, old_path)
  input = vim.trim(input or "")
  if input == "" then
    return nil
  end

  if not is_absolute_path(input) then
    input = vim.fs.joinpath(vim.fs.dirname(old_path), input)
  end

  return normalize_path(input)
end

local function prompt_new_path(old_path)
  vim.fn.inputsave()
  local ok, input = pcall(vim.fn.input, "New file path: ", old_path, "file")
  vim.fn.inputrestore()

  if not ok then
    notify("File rename cancelled", vim.log.levels.INFO)
    return nil
  end

  return input
end

local function notify_did_rename(clients, old_uri, new_uri)
  local params = {
    files = {
      { oldUri = old_uri, newUri = new_uri },
    },
  }

  for _, client in ipairs(clients) do
    if file_operation_capability(client, "didRename") then
      client:notify("workspace/didRenameFiles", params)
    end
  end
end

function M.rename_file(opts)
  opts = opts or {}
  local bufnr = opts.bufnr or vim.api.nvim_get_current_buf()
  local old_name = vim.api.nvim_buf_get_name(bufnr)

  if old_name == "" then
    notify("Current buffer has no file name", vim.log.levels.ERROR)
    return false
  end

  local old_path = normalize_path(old_name)

  local input = opts.new_path or prompt_new_path(old_path)
  local new_path = resolve_new_path(input, old_path)
  if not new_path or new_path == old_path then
    return false
  end

  if not uv.fs_stat(old_path) then
    notify("Cannot rename a file that does not exist on disk", vim.log.levels.ERROR)
    return false
  end
  if uv.fs_stat(new_path) then
    notify("Target file already exists: " .. new_path, vim.log.levels.ERROR)
    return false
  end
  if not uv.fs_stat(vim.fs.dirname(new_path)) then
    notify("Target directory does not exist: " .. vim.fs.dirname(new_path), vim.log.levels.ERROR)
    return false
  end

  local clients = get_file_rename_clients(bufnr, opts.client_name)
  if #clients == 0 then
    notify("No attached TypeScript client supports workspace/willRenameFiles", vim.log.levels.ERROR)
    return false
  end

  local old_uri = vim.uri_from_fname(old_path)
  local new_uri = vim.uri_from_fname(new_path)
  local rename_params = {
    files = {
      { oldUri = old_uri, newUri = new_uri },
    },
  }
  local touched_states = {}

  for _, client in ipairs(clients) do
    local response = client:request_sync("workspace/willRenameFiles", rename_params, FILE_RENAME_TIMEOUT_MS, bufnr)
    if not response then
      notify("Timed out requesting file rename edits from " .. client.name, vim.log.levels.ERROR)
      return false
    end
    if response.err then
      notify(
        "Failed to request file rename edits from "
          .. client.name
          .. ": "
          .. tostring(response.err.message or response.err),
        vim.log.levels.ERROR
      )
      return false
    end

    if response.result and response.result ~= vim.NIL then
      remember_edit_paths(touched_states, collect_workspace_edit_paths(response.result), old_path, new_path)
      local ok, err = pcall(vim.lsp.util.apply_workspace_edit, response.result, client.offset_encoding or "utf-16")
      if not ok then
        notify("Failed to apply file rename edits: " .. tostring(err), vim.log.levels.ERROR)
        return false
      end
    end
  end

  local skipped = save_touched_buffers(touched_states)
  local renamed, rename_err = uv.fs_rename(old_path, new_path)
  if not renamed then
    notify("Failed to rename file: " .. tostring(rename_err), vim.log.levels.ERROR)
    return false
  end

  local named, name_err = pcall(vim.api.nvim_buf_set_name, bufnr, new_path)
  if not named then
    pcall(uv.fs_rename, new_path, old_path)
    notify("Failed to update buffer name: " .. tostring(name_err), vim.log.levels.ERROR)
    return false
  end

  if vim.bo[bufnr].modified then
    local ok, err = pcall(vim.api.nvim_buf_call, bufnr, function()
      vim.cmd("silent write")
    end)
    if not ok then
      notify("Renamed file, but failed to write current buffer: " .. tostring(err), vim.log.levels.ERROR)
      return false
    end
  end

  notify_did_rename(clients, old_uri, new_uri)
  notify("Renamed " .. vim.fn.fnamemodify(old_path, ":t") .. " to " .. vim.fn.fnamemodify(new_path, ":t"))

  if #skipped > 0 then
    notify(
      "Some updated buffers already had unsaved changes and were not written: " .. table.concat(skipped, ", "),
      vim.log.levels.WARN
    )
  end

  return true
end

return M
