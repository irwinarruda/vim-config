local M = {}

local function get_tailwind_client(bufnr)
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
    if client.name == "tailwindcss" then
      return client
    end
  end

  return nil
end

local function is_tailwind_diagnostic(diagnostic)
  if not diagnostic then
    return false
  end

  if diagnostic.source == "tailwindcss" then
    return true
  end

  local lsp_diagnostic = diagnostic.user_data and diagnostic.user_data.lsp

  return lsp_diagnostic and lsp_diagnostic.source == "tailwindcss"
end

local function get_tailwind_diagnostics(bufnr, client)
  local diagnostics = {}
  local has_namespace = false
  local ok, namespace = pcall(vim.lsp.diagnostic.get_namespace, client.id)

  if ok and namespace then
    diagnostics = vim.diagnostic.get(bufnr, { namespace = namespace })
    has_namespace = #diagnostics > 0
  end

  if has_namespace then
    return diagnostics
  end

  return vim.tbl_filter(is_tailwind_diagnostic, vim.diagnostic.get(bufnr))
end

local function group_diagnostics_by_line(diagnostics)
  local grouped = {}

  for _, diagnostic in ipairs(diagnostics) do
    local key = tostring(diagnostic.lnum)
    local group = grouped[key]

    if not group then
      group = {
        lnum = diagnostic.lnum,
        start_col = diagnostic.col,
        end_col = diagnostic.end_col or diagnostic.col,
        diagnostics = {},
      }
      grouped[key] = group
    end

    group.start_col = math.min(group.start_col, diagnostic.col)
    group.end_col = math.max(group.end_col, diagnostic.end_col or diagnostic.col)
    table.insert(group.diagnostics, diagnostic)
  end

  local lines = vim.tbl_values(grouped)

  table.sort(lines, function(a, b)
    return a.lnum > b.lnum
  end)

  return lines
end

local function to_lsp_diagnostic(diagnostic)
  local lsp_diagnostic = diagnostic.user_data and diagnostic.user_data.lsp

  if lsp_diagnostic then
    return vim.deepcopy(lsp_diagnostic)
  end

  return {
    range = {
      start = {
        line = diagnostic.lnum,
        character = diagnostic.col,
      },
      ["end"] = {
        line = diagnostic.end_lnum or diagnostic.lnum,
        character = diagnostic.end_col or diagnostic.col,
      },
    },
    message = diagnostic.message,
    severity = diagnostic.severity,
    source = diagnostic.source,
    code = diagnostic.code,
    data = diagnostic.data,
  }
end

local function make_code_action_params(bufnr, group)
  local lsp_diagnostics = vim.tbl_map(to_lsp_diagnostic, group.diagnostics)

  return {
    textDocument = vim.lsp.util.make_text_document_params(bufnr),
    range = {
      start = {
        line = group.lnum,
        character = group.start_col,
      },
      ["end"] = {
        line = group.lnum,
        character = group.end_col,
      },
    },
    context = {
      diagnostics = lsp_diagnostics,
      triggerKind = vim.lsp.protocol.CodeActionTriggerKind.Automatic,
    },
  }
end

local function normalize_action(action)
  if action.edit or action.command then
    return action
  end

  return {
    title = action.title,
    kind = action.kind,
    edit = action.edit,
    command = action.command,
    isPreferred = action.isPreferred,
    disabled = action.disabled,
    data = action.data,
  }
end

local function select_action(actions)
  local fallback = nil

  for _, action in ipairs(actions or {}) do
    if not action.disabled then
      local normalized = normalize_action(action)

      if normalized.isPreferred then
        return normalized
      end

      if not fallback then
        fallback = normalized
      end
    end
  end

  return fallback
end

local function apply_action(client, action, bufnr)
  if action.edit then
    vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding)
  end

  local command = action.command

  if not command then
    return
  end

  if type(command) == "table" then
    client:exec_cmd(command, { bufnr = bufnr })
    return
  end

  client:exec_cmd({
    command = command,
    arguments = action.arguments,
    title = action.title,
  }, { bufnr = bufnr })
end

local function get_action_for_group(client, bufnr, group)
  local responses = vim.lsp.buf_request_sync(
    bufnr,
    "textDocument/codeAction",
    make_code_action_params(bufnr, group),
    1000
  )

  if not responses then
    return nil
  end

  local response = responses[client.id]

  if not response or not response.result or #response.result == 0 then
    return nil
  end

  return select_action(response.result)
end

function M.apply_buffer_suggestions()
  local bufnr = vim.api.nvim_get_current_buf()
  local client = get_tailwind_client(bufnr)

  if not client then
    vim.notify(
      "No tailwindcss LSP client attached to the current buffer.",
      vim.log.levels.WARN
    )
    return
  end

  local applied = 0

  for _ = 1, 10 do
    local diagnostics = get_tailwind_diagnostics(bufnr, client)

    if #diagnostics == 0 then
      break
    end

    local pass_applied = 0
    local groups = group_diagnostics_by_line(diagnostics)

    for _, group in ipairs(groups) do
      local action = get_action_for_group(client, bufnr, group)

      if action then
        apply_action(client, action, bufnr)
        applied = applied + 1
        pass_applied = pass_applied + 1
      end
    end

    if pass_applied == 0 then
      break
    end
  end

  if applied == 0 then
    vim.notify(
      "No Tailwind LSP fixes were available for the current buffer.",
      vim.log.levels.INFO
    )
    return
  end

  vim.notify(
    string.format("Applied %d Tailwind LSP fix(es) in the current buffer.", applied),
    vim.log.levels.INFO
  )
end

function M.setup()
  vim.api.nvim_create_user_command("TailwindApplyBufferSuggestions", function()
    M.apply_buffer_suggestions()
  end, {
    desc = "Apply all available Tailwind LSP fixes in the current buffer",
  })
end

return M
