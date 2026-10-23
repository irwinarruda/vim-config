return {
  "saghen/blink.cmp",
  version = "1.*", -- release tags ship the prebuilt Rust fuzzy matcher
  event = "InsertEnter",
  dependencies = { "nvim-os-persist" },
  opts = function()
    local os = require("nvim-os-persist")

    return {
      keymap = {
        preset = "none",
        ["<C-p>"] = {
          "select_prev",
          function() -- paste the clipboard when the menu is closed
            vim.api.nvim_feedkeys(vim.keycode("<C-r>+"), "i", false)
            return true
          end,
        },
        ["<C-n>"] = { "select_next", "fallback" },
        ["<Up>"] = { "select_prev", "fallback" },
        ["<Down>"] = { "select_next", "fallback" },
        ["<C-k>"] = { "select_prev", "fallback" }, -- previous suggestion
        ["<C-j>"] = { "select_next", "fallback" }, -- next suggestion
        [os.motion("cmp_complete")] = { "show" }, -- show completion suggestions
        ["<C-q>"] = { "cancel", "fallback" }, -- close completion window
        ["<C-e>"] = { "cancel", "fallback" },
        ["<C-y>"] = { "accept", "fallback" },
        ["<CR>"] = { "select_and_accept", "fallback" },
      },
      completion = {
        -- Nothing is highlighted until you move; <CR> takes the first item
        list = { selection = { preselect = false, auto_insert = false } },
        -- No "()" after functions, same as typescript-tools' complete_function_calls = false
        accept = { auto_brackets = { enabled = false } },
        documentation = { auto_show = true },
      },
      sources = {
        default = { "lazydev", "lsp", "path", "snippets", "buffer" },
        providers = {
          lazydev = { name = "LazyDev", module = "lazydev.integrations.blink", score_offset = 100 },
        },
      },
      cmdline = { enabled = false }, -- keep noice's command line as it is
    }
  end,
}
