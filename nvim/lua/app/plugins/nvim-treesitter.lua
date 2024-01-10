local s1, nvimtreesitter = pcall(require, "nvim-treesitter.configs")
local s2, nvimtreesittercontext = pcall(require, "treesitter-context")
local s3, nvimautotag = pcall(require, "nvim-ts-autotag")

if not s1 or not s2 or not s3 then
  return
end

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
    "svelte",
    "vue",
    "java",
    "json",
    "xml",
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
  },
})

nvimtreesittercontext.setup()
nvimautotag.setup()

-- on windows
-- local s2, nvimtreesitterinstall = pcall(require, "nvim-treesitter.install")
-- if not s2 then
--   return
-- end
-- nvimtreesitterinstall.compilers = { "clang" }
