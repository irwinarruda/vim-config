local s1, telescope = pcall(require, "telescope")
local s2, actions = pcall(require, "telescope.actions")

if not s1 or not s2 then
  return
end

telescope.setup({
  defaults = {
    mappings = {
      i = {
        ["<C-k>"] = actions.move_selection_previous, -- move to prev result
        ["<C-j>"] = actions.move_selection_next, -- move to next result
        ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
        ["<C-c>"] = actions.close,
      },
    },
  },
})

local builtin = require("telescope.builtin")
local keymap = vim.keymap
keymap.set("n", "<leader>fo", builtin.find_files) -- find files within current working directory, respects .gitignore
keymap.set("n", "<leader>fp", builtin.git_files) -- find files in git
keymap.set("n", "<leader>ff", builtin.live_grep) -- find string in current working directory as you type
keymap.set("n", "<leader>fb", builtin.buffers) -- find string in current working directory as you type
keymap.set("n", "<leader>fg", function()
  builtin.grep_string({ search = vim.fn.input("Grep > ") })
end) -- find string in current working directory as you type

local telescope_lsp_keymaps = function(opts)
  vim.keymap.set("n", "<C-,>", function()
    builtin.lsp_definitions()
  end, opts)
  vim.keymap.set("n", "<C-m>", function()
    builtin.lsp_references()
  end, opts)
  vim.keymap.set("n", "<leader>.", function()
    builtin.diagnostics()
  end, opts)
end

return {
  telescope_lsp_keymaps = telescope_lsp_keymaps,
}
