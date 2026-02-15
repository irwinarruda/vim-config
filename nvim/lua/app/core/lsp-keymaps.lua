local M = {}

local function setup_default_lsp_keymaps(opts, os, builtin)
  vim.keymap.set("n", os.motion("lsp_definitions"), vim.lsp.buf.definition, opts)
  vim.keymap.set("n", os.motion("lsp_references"), builtin.lsp_references, opts)
  vim.keymap.set("n", os.motion("lsp_implementation"), builtin.lsp_implementations, opts)
end

function M.setup(opts)
  local builtin = require("telescope.builtin")
  local os = require("nvim-os-persist")
  local has_omnisharp = false
  local bufnr = opts and opts.buffer or 0

  for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
    if client.name == "omnisharp" or client.name == "omnisharp_mono" then
      has_omnisharp = true
      break
    end
  end

  if has_omnisharp then
    local ok, omnisharp = pcall(require, "omnisharp_extended")
    if ok then
      vim.keymap.set("n", os.motion("lsp_definitions"), omnisharp.telescope_lsp_definition, opts)
      vim.keymap.set("n", os.motion("lsp_references"), omnisharp.telescope_lsp_references, opts)
      vim.keymap.set("n", os.motion("lsp_implementation"), omnisharp.telescope_lsp_implementation, opts)
    else
      setup_default_lsp_keymaps(opts, os, builtin)
    end
  else
    setup_default_lsp_keymaps(opts, os, builtin)
  end

  vim.keymap.set("n", "<leader>.", builtin.diagnostics, opts)
end

return M
