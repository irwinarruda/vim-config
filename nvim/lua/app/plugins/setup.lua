-- Start Config Packer
vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost setup.lua source <afile> | PackerSync
  augroup end
]])

local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({ "git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path })
    vim.cmd([[packadd packer.nvim]])
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

local status, packer = pcall(require, "packer")
if not status then
  return
end

return packer.startup(function(use)
  use("wbthomason/packer.nvim")
  use("mg979/vim-visual-multi")
  use("christoomey/vim-tmux-navigator")
  use("szw/vim-maximizer")
  -- Comment code
  use("numToStr/Comment.nvim")
  use("folke/todo-comments.nvim")
  -- Autoclose
  use("m4xshen/autoclose.nvim")
  -- Color Highlight for hex colors
  use("norcalli/nvim-colorizer.lua")
  use("hiphish/rainbow-delimiters.nvim")
  -- File explorer | Status Line
  use("nvim-lualine/lualine.nvim")
  use("nvim-tree/nvim-web-devicons")
  use("nvim-tree/nvim-tree.lua")
  use("stevearc/dressing.nvim")
  use("nvimdev/lspsaga.nvim")
  -- Tabs
  use({
    "theprimeagen/harpoon",
    branch = "harpoon2",
    requires = { { "nvim-lua/plenary.nvim" } },
  })
  -- Undo History
  use("mbbill/undotree")
  -- Fuzzy finding w/ telescope
  -- If not working, do :checkhealth telescope to download the other plugins
  use({
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    requires = { { "nvim-lua/plenary.nvim" } },
  })
  -- treesitter configuration
  use({
    "nvim-treesitter/nvim-treesitter",
    run = function()
      local ts_update = require("nvim-treesitter.install").update({ with_sync = true })
      ts_update()
    end,
  })
  use("nvim-treesitter/nvim-treesitter-context")
  -- LSP
  use("saadparwaiz1/cmp_luasnip") -- for autocompletion
  use("windwp/nvim-ts-autotag")
  use({
    "vonheikemen/lsp-zero.nvim",
    branch = "v3.x",
    requires = {
      { "williamboman/mason.nvim" },
      { "williamboman/mason-lspconfig.nvim" },
      -- LSP Support
      { "neovim/nvim-lspconfig" },
      -- Autocompletion
      { "hrsh7th/nvim-cmp" },
      { "hrsh7th/cmp-nvim-lsp" },
      { "L3MON4D3/LuaSnip" },
    },
  })
  use({
    "pmizio/typescript-tools.nvim",
    requires = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
  })
  use("stevearc/conform.nvim")
  use("mfussenegger/nvim-lint")
  use("mfussenegger/nvim-dap")
  use({ "rcarriga/nvim-dap-ui", requires = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" } })
  use({ "mxsdev/nvim-dap-vscode-js", requires = { "mfussenegger/nvim-dap" } })
  use("theHamsta/nvim-dap-virtual-text")
  use({
    "microsoft/vscode-js-debug",
    opt = true,
    run = "npm install && npx gulp vsDebugServerBundle && mv dist out",
  })
  use("nvim-telescope/telescope-dap.nvim")
  use("folke/neodev.nvim")
  -- Github
  use("github/copilot.vim")
  use("lewis6991/gitsigns.nvim")
  -- Identing line
  use("echasnovski/mini.indentscope")
  -- Terminal
  use("akinsho/toggleterm.nvim")
  -- Template Strings
  use("axelvc/template-string.nvim")
  -- Themes
  -- use("dracula/vim")

  if packer_bootstrap then
    require("packer").sync()
  end
end)
