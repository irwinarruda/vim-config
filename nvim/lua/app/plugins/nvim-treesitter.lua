return {
  "nvim-treesitter/nvim-treesitter",
  event = { "BufReadPre", "BufNewFile" },
  build = ":TSUpdate",
  dependencies = {
    "nvim-treesitter/nvim-treesitter-context",
    "windwp/nvim-ts-autotag",
  },
  config = function()
    local nvimtreesitter = require("nvim-treesitter.configs")
    local nvimtreesittercontext = require("treesitter-context")
    local nvimautotag = require("nvim-ts-autotag")

    local os = require("nvim-os-persist")
    if os:is_windows() then
      local nvimtreesitterinstall = require("nvim-treesitter.install")
      nvimtreesitterinstall.compilers = { "clang" }
    end

    ---@diagnostic disable-next-line: missing-fields
    nvimtreesitter.setup({
      ensure_installed = {
        "c",
        "cpp",
        "lua",
        "vim",
        "vimdoc",
        "html",
        "typescript",
        "javascript",
        "tsx",
        "jsdoc",
        "rust",
        "svelte",
        "vue",
        "java",
        "json",
        "xml",
        "go",
        "gomod",
        "templ",
        "python",
        "regex",
        "markdown",
        "markdown_inline",
      },
      sync_install = false,
      autoinstall = true,
      autotag = {
        enable = true,
        enable_rename = true,
        enable_close = true,
        enable_close_on_slash = true,
      },
      indent = { enable = true },
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
        disable = { "css", "scss" },
      },
    })

    nvimtreesittercontext.setup({
      multiline_threshold = 1,
    })
    nvimautotag.setup()
  end,
}
