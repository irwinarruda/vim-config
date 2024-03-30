local s1, nvimtreesitter = pcall(require, "nvim-treesitter.configs")
local s2, nvimtreesittercontext = pcall(require, "treesitter-context")
local s3, nvimautotag = pcall(require, "nvim-ts-autotag")

if not s1 or not s2 or not s3 then
  return
end

---@diagnostic disable-next-line: missing-fields
nvimtreesitter.setup({
  ensure_installed = {
    "c",
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
  },
  sync_install = false,
  autoinstall = true,
  autotag = {
    enable = true,
    enable_rename = true,
    enable_close = true,
    enable_close_on_slash = true,
  },
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

local os = require("app.libs.os")
if os:is_windows() then
  local nvimtreesitterinstall = require("nvim-treesitter.install")
  nvimtreesitterinstall.compilers = { "clang" }
end
