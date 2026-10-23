local PARSERS = {
  "c",
  "cpp",
  "c_sharp",
  "lua",
  "vim",
  "vimdoc",
  "sql",
  "html",
  "typescript",
  "javascript",
  "tsx",
  "jsdoc",
  "rust",
  "svelte",
  "vue",
  "java",
  "kotlin",
  "json",
  "xml",
  "go",
  "gomod",
  "templ",
  "python",
  "regex",
  "markdown",
  "markdown_inline",
  "css",
  "scss",
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false, -- the main branch does not support lazy-loading
    build = ":TSUpdate",
    config = function()
      vim.treesitter.language.register("markdown", "mdx")
      require("nvim-treesitter").install(PARSERS)

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("app_treesitter", { clear = true }),
        desc = "Start treesitter highlighting and indentation",
        callback = function(event)
          if not pcall(vim.treesitter.start, event.buf) then
            return
          end
          -- Keep regex highlighting alongside treesitter (additional_vim_regex_highlighting)
          vim.bo[event.buf].syntax = "ON"

          local lang = vim.treesitter.language.get_lang(vim.bo[event.buf].filetype)
          if lang and vim.treesitter.query.get(lang, "indents") then
            vim.bo[event.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      multiline_threshold = 1,
    },
  },
  {
    "windwp/nvim-ts-autotag",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      opts = {
        enable = true, -- Enable autotag
        enable_close = true, -- Auto close tags
        enable_rename = true, -- Auto rename pairs of tags
        enable_close_on_slash = true, -- Auto close on trailing </
      },
    },
  },
}
