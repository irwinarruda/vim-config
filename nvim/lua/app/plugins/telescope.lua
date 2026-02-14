local telescope_lsp_keymaps = function(opts)
  local builtin = require("telescope.builtin")
  local os = require("app.plugins.nvim-os-persist")
  local has_omnisharp = false
  local bufnr = opts and opts.buffer or 0
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
    if client.name == "omnisharp" or client.name == "omnisharp_mono" then
      has_omnisharp = true
      break
    end
  end
  if has_omnisharp then
    local omnisharp = require("omnisharp_extended")
    vim.keymap.set("n", os.motion("lsp_definitions"), omnisharp.telescope_lsp_definition, opts)
    vim.keymap.set("n", os.motion("lsp_references"), omnisharp.telescope_lsp_references, opts)
    vim.keymap.set("n", os.motion("lsp_implementation"), omnisharp.telescope_lsp_implementation, opts)
  else
    vim.keymap.set("n", os.motion("lsp_definitions"), vim.lsp.buf.definition, opts)
    vim.keymap.set("n", os.motion("lsp_references"), builtin.lsp_references, opts)
    vim.keymap.set("n", os.motion("lsp_implementation"), builtin.lsp_implementations, opts)
  end
  vim.keymap.set("n", "<leader>.", builtin.diagnostics, opts)
end

return {
  "nvim-telescope/telescope.nvim",
  branch = "master",
  dependencies = { "nvim-telescope/telescope-dap.nvim", "nvim-lua/plenary.nvim" },
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")

    local ignore_file = vim.fn.stdpath("config") .. "/lua/app/plugins/.telescope_ignore"
    local dropdown_config = {
      theme = "dropdown",
      layout_config = {
        preview_cutoff = 1,
        width = function(_, max_columns, _)
          return math.min(max_columns, 90)
        end,
        height = function(_, _, max_lines)
          return math.min(max_lines, 15)
        end,
      },
    }

    telescope.setup({
      defaults = {
        mappings = {
          i = {
            ["<C-k>"] = actions.move_selection_previous, -- move to prev result
            ["<C-j>"] = actions.move_selection_next, -- move to next result
            ["<C-q>"] = actions.send_to_qflist + actions.open_qflist, -- move results to quickfix list
            ["<C-c>"] = actions.close, -- close telescope
          },
        },
      },
      pickers = {
        find_files = vim.tbl_extend("force", dropdown_config, {
          find_command = {
            "rg",
            "--files",
            "--hidden",
            "--no-ignore",
            "--ignore-file",
            ignore_file,
          },
        }),
        git_files = dropdown_config,
        buffers = dropdown_config,
        live_grep = vim.tbl_extend("force", dropdown_config, {
          additional_args = function()
            return {
              "--hidden",
              "--no-ignore",
              "--ignore-file",
              ignore_file,
            }
          end,
        }),
        lsp_references = dropdown_config,
        lsp_definitions = dropdown_config,
        diagnostics = dropdown_config,
      },
    })

    telescope.load_extension("dap")

    local builtin = require("telescope.builtin")
    local keymap = vim.keymap
    keymap.set("n", "<leader>fo", builtin.find_files) -- find files using custom ignore patterns
    keymap.set("n", "<leader>fp", builtin.git_files) -- find files in git
    keymap.set("n", "<leader>fg", builtin.git_status) -- find in changed files
    keymap.set("n", "<leader>ff", builtin.live_grep) -- find string in current working directory as you type
    keymap.set("n", "<leader>fb", builtin.buffers) -- find string in current working directory as you type
  end,
  telescope_lsp_keymaps = telescope_lsp_keymaps,
}
