return {
  "nvim-tree/nvim-tree.lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local nvim_tree = require("nvim-tree")
    local nvim_devicons = require("nvim-web-devicons")

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
      reload_on_bufenter = false,
      view = {
        width = 28,
        preserve_window_proportions = true,
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
      local nvimtree = require("nvim-tree.api")
      nvimtree.tree.toggle({ find_file = true, focus = false })
    end, { noremap = true })

    vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
      group = vim.api.nvim_create_augroup("NvimTreeOnOpen", { clear = false }),
      desc = "Find file on open",
      pattern = "*",
      callback = function()
        local nvimtree = require("nvim-tree.api")
        nvimtree.tree.find_file({ open = false, focus = false })
      end,
    })
  end,
}
