local WIDTH = 28

local git = {
  icon = "󰊢",
  color = "#df3429",
  name = "GitLogo",
}

local webpack = {
  icon = "",
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

return {
  {
    "nvim-tree/nvim-web-devicons",
    opts = {
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
    },
  },
  {
    "nvim-tree/nvim-tree.lua",
    lazy = false,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      reload_on_bufenter = true,
      view = {
        width = WIDTH,
        preserve_window_proportions = true,
      },
      actions = {
        open_file = {
          resize_window = false,
        },
      },
      git = {
        ignore = false,
      },
      -- Reveal the current buffer in the tree when it is open
      update_focused_file = {
        enable = true,
      },
    },
    config = function(_, opts)
      require("nvim-tree").setup(opts)

      -- Toggle the tree but reopen it at whatever width it was resized to
      local current_width = WIDTH
      vim.keymap.set("n", "<leader>e", function()
        local api = require("nvim-tree.api")
        local tree_win = api.tree.winid()
        if tree_win then
          current_width = vim.api.nvim_win_get_width(tree_win)
        end

        api.tree.toggle({ find_file = true, focus = false })
        vim.cmd("NvimTreeResize " .. current_width)
      end)
    end,
  },
}
