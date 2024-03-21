local s1, nvim_tree = pcall(require, "nvim-tree")
local s2, nvim_tree_api = pcall(require, "nvim-tree.api")
local s3, nvim_devicons = pcall(require, "nvim-web-devicons")

if not s1 or not s2 or not s3 then
  return
end

local git = {
  icon = "󰊢",
  color = "#df3429",
  name = "GitLogo",
}

local webpack = {
  icon = "",
  color = "#86d3f7",
  name = "Webpack",
}

local env = {
  icon = "󰙪",
  color = "#f9b540",
  name = "Env",
}

local eslint = {
  icon = "󰱺",
  color = "#384aa7",
  name = "Eslint",
}

nvim_devicons.setup({
  override = {
    ["git"] = git,
    ["env"] = env,
  },
  override_by_filename = {
    ["webpack.config.js"] = webpack,
    [".env.local"] = env,
    [".env.development"] = env,
    [".env.production"] = env,
    [".eslintrc"] = eslint,
    [".eslintrc.json"] = eslint,
    [".eslintrc.js"] = eslint,
    [".gitignore"] = git,
    [".gitattributes"] = git,
  },
})

vim.g.loaded = 1
vim.g.loaded_netrwPlugin = 1
nvim_tree.setup({
  view = {
    preserve_window_proportions = false,
  },
  actions = {
    open_file = {
      resize_window = true,
    },
  },
  git = {
    ignore = false,
  },
})

vim.keymap.set("n", "<Space>e", function()
  nvim_tree_api.tree.toggle({ find_file = true, focus = false })
end, { noremap = true })

vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
  group = vim.api.nvim_create_augroup("NvimTreeOnOpen", { clear = false }),
  desc = "Find file on open",
  pattern = "*",
  callback = function()
    local nvim_tree = require("nvim-tree.api")
    nvim_tree.tree.find_file({ open = false, focus = false })
  end,
})
