return {
  -- Neovim's built-in commenting (gc) plus treesitter-aware commentstrings (e.g. JSX)
  "JoosepAlviste/nvim-ts-context-commentstring",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = { "nvim-os-persist" },
  opts = {
    enable_autocmd = false,
  },
  config = function(_, opts)
    require("ts_context_commentstring").setup(opts)

    -- gc asks for each language's commentstring through this; answer from the cursor's context
    local get_option = vim.filetype.get_option
    ---@diagnostic disable-next-line: duplicate-set-field
    vim.filetype.get_option = function(filetype, option)
      return option == "commentstring" and require("ts_context_commentstring.internal").calculate_commentstring()
        or get_option(filetype, option)
    end

    local os = require("nvim-os-persist")
    vim.keymap.set("n", os.motion("comment"), "gcc", { remap = true, desc = "Toggle comment" })
    vim.keymap.set("x", os.motion("comment"), "gcgv", { remap = true, desc = "Toggle comment, keep selection" })
  end,
}
