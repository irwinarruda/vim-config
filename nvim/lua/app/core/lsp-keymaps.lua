local M = {}

local function code_action()
  require("lspsaga.command").load_command("code_action")
end

--- Keymaps shared by every LSP client, keyed by their nvim-os-persist name.
local function default_keymaps()
  local builtin = require("telescope.builtin")

  return {
    lsp_definitions = builtin.lsp_definitions,
    lsp_references = builtin.lsp_references,
    lsp_implementation = builtin.lsp_implementations,
    lsp_diagnostic = builtin.diagnostics,
    -- Calling twice opens the float, then jumps into it
    lsp_hover_diagnostic = function()
      vim.diagnostic.open_float()
      vim.diagnostic.open_float()
    end,
    lsp_hover = function()
      vim.lsp.buf.hover()
      vim.defer_fn(vim.lsp.buf.hover, 80)
    end,
    lsp_code_action = code_action,
    lsp_rename = vim.lsp.buf.rename,
    lsp_goto_next = function()
      vim.diagnostic.jump({ count = 1 })
      vim.cmd.normal("zz")
    end,
    lsp_goto_prev = function()
      vim.diagnostic.jump({ count = -1 })
      vim.cmd.normal("zz")
    end,
  }
end

--- Runs `fn` once vtsls is attached to `buf`. With tsc as the main server, this is
--- what starts vtsls: the first time one of its keymaps is used.
local function with_vtsls(buf, fn)
  if #vim.lsp.get_clients({ bufnr = buf, name = "vtsls" }) > 0 then
    return fn()
  end

  vim.api.nvim_create_autocmd("LspAttach", {
    buf = buf,
    callback = function(event)
      if vim.lsp.get_client_by_id(event.data.client_id).name == "vtsls" then
        vim.schedule(fn)
        return true -- delete this autocmd
      end
    end,
  })
  vim.lsp.enable("vtsls")
end

--- Import/file keymaps. typescript-tools has its own commands; tsc and vtsls use vtsls.
local function typescript_keymaps(typescript_lsp, buf)
  if typescript_lsp == "typescript-tools" then
    return {
      lsp_ts_rename_file = "<cmd>TSToolsRenameFile<CR>",
      lsp_ts_remove_imports = "<cmd>TSToolsRemoveUnusedImports<CR>",
      lsp_ts_sort_imports = "<cmd>TSToolsSortImports<CR>",
    }
  end

  local commands = require("vtsls").commands
  local function vtsls(fn)
    return function()
      with_vtsls(buf, fn)
    end
  end

  local keymaps = {
    -- tsc has no quick-fixes, so code actions in TS buffers come from vtsls
    lsp_code_action = vtsls(code_action),
    lsp_ts_rename_file = vtsls(function()
      commands.rename_file(buf)
    end),
    lsp_ts_remove_imports = vtsls(function()
      commands.remove_unused_imports(buf)
    end),
    lsp_ts_sort_imports = vtsls(function()
      commands.sort_imports(buf)
    end),
  }
  if typescript_lsp == "vtsls" then
    keymaps.lsp_ts_select_version = function()
      commands.select_ts_version(buf)
    end
  end
  return keymaps
end

--- @param typescript_lsp string the active TypeScript server (see app.core.typescript-lsp)
function M.setup(typescript_lsp)
  local os = require("nvim-os-persist")

  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("app_lsp_keymaps", { clear = true }),
    callback = function(event)
      local buf = event.buf
      local keymaps = default_keymaps()

      -- Re-applied on every attach, so vtsls joining later keeps the TS keymaps
      if #vim.lsp.get_clients({ bufnr = buf, name = typescript_lsp }) > 0 then
        keymaps = vim.tbl_extend("force", keymaps, typescript_keymaps(typescript_lsp, buf))
      end

      for name, rhs in pairs(keymaps) do
        vim.keymap.set("n", os.motion(name), rhs, { buf = buf })
      end
      vim.keymap.set("n", "<leader>h", function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
      end, { buf = buf })
    end,
  })
end

return M
