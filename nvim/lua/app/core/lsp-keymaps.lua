local M = {}

local function setup_default_lsp_keymaps(opts, os, builtin)
  vim.keymap.set("n", os.motion("lsp_definitions"), builtin.lsp_definitions, opts)
  vim.keymap.set("n", os.motion("lsp_references"), builtin.lsp_references, opts)
  vim.keymap.set("n", os.motion("lsp_implementation"), builtin.lsp_implementations, opts)
end

function M.setup(opts)
  local builtin = require("telescope.builtin")
  local os = require("nvim-os-persist")

  setup_default_lsp_keymaps(opts, os, builtin)
  vim.keymap.set("n", "<leader>.", builtin.diagnostics, opts)
end

return M
