return {
  "nvim-treesitter/nvim-treesitter",
  event = { "BufReadPre", "BufNewFile" },
  build = ":TSUpdate",
  dependencies = {
    "nvim-treesitter/nvim-treesitter-context",
    "windwp/nvim-ts-autotag",
    "nvim-os-persist",
  },
  config = function()
    local nvimtreesitter = require("nvim-treesitter.configs")
    local nvimtreesittercontext = require("treesitter-context")
    local nvimautotag = require("nvim-ts-autotag")

    local os = require("nvim-os-persist")
    if os:is_windows() then
      local nvimtreesitterinstall = require("nvim-treesitter.install")
      nvimtreesitterinstall.compilers = { "clang", "zig" }
      nvimtreesitterinstall.prefer_git = false
    end

    ---@diagnostic disable-next-line: missing-fields
    nvimtreesitter.setup({
      ensure_installed = {
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
      },
      sync_install = false,
      autoinstall = true,
      indent = { enable = true },
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = true,
        -- disable = { "css", "scss" },
      },
    })
    nvimtreesittercontext.setup({
      multiline_threshold = 1,
    })
    nvimautotag.setup({
      opts = {
        enable = true,                -- Enable autotag
        enable_close = true,          -- Auto close tags
        enable_rename = true,         -- Auto rename pairs of tags
        enable_close_on_slash = true, -- Auto close on trailing </
      },
    })
  end,
}
