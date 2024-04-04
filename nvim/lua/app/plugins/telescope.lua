local s1, telescope = pcall(require, "telescope")
local s2, actions = pcall(require, "telescope.actions")

if not s1 or not s2 then
  return
end

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
    find_files = dropdown_config,
    git_files = dropdown_config,
    buffers = dropdown_config,
    live_grep = dropdown_config,
    lsp_references = dropdown_config,
    lsp_definitions = dropdown_config,
    diagnostics = dropdown_config,
  },
})

telescope.load_extension("dap")

local builtin = require("telescope.builtin")
local keymap = vim.keymap
keymap.set("n", "<leader>fo", function()
  builtin.find_files({ hidden = true })
end) -- find files within current working directory, respects .gitignore
keymap.set("n", "<leader>fp", builtin.git_files) -- find files in git
keymap.set("n", "<leader>fg", builtin.git_status) -- find in changed files
keymap.set("n", "<leader>ff", builtin.live_grep) -- find string in current working directory as you type
keymap.set("n", "<leader>fb", builtin.buffers) -- find string in current working directory as you type

local telescope_lsp_keymaps = function(opts)
  local os = require("nvim-os-persist")
  vim.keymap.set("n", os.keymap("lsp_definitions"), function()
    builtin.lsp_definitions()
  end, { noremap = true, buffer = opts.buffer })
  vim.keymap.set("n", os.keymap("lsp_references"), function()
    builtin.lsp_references()
  end, opts)
  vim.keymap.set("n", "<leader>.", function()
    builtin.diagnostics()
  end, opts)
end

return {
  telescope_lsp_keymaps = telescope_lsp_keymaps,
}
