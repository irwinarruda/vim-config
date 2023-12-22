-- Start Config Packer
vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost setup.lua source <afile> | PackerSync
  augroup end
]])

local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
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

return packer.startup(function (use)
  use('wbthomason/packer.nvim')
  use('mg979/vim-visual-multi')
  use('christoomey/vim-tmux-navigator')
  use('szw/vim-maximizer')
  -- Comment code with gc
  use('numToStr/Comment.nvim')
  -- File explorer
  use('nvim-tree/nvim-tree.lua')
  -- Icons for files
  use('kyazdani42/nvim-web-devicons')
  -- Statusline
  use('nvim-lualine/lualine.nvim')
  -- Fuzzy finding w/ telescope
  -- If not working, do :checkhealth telescope to download the other plugins
  use('nvim-lua/plenary.nvim')
  use({
    'nvim-telescope/telescope.nvim', tag = '0.1.x',
    requires = { {'nvim-lua/plenary.nvim'} }
  })
  -- Autocompletion
  use("hrsh7th/nvim-cmp") -- completion plugin
  use("hrsh7th/cmp-buffer") -- source for text in buffer
  use("hrsh7th/cmp-path") -- source for file system paths
  -- Snippets
  use("L3MON4D3/LuaSnip") -- snippet engine
  use("saadparwaiz1/cmp_luasnip") -- for autocompletion
  use("rafamadriz/friendly-snippets") -- useful snippets
  -- LSP
  use('williamboman/mason.nvim')
  use('williamboman/mason-lspconfig.nvim')
  use('neovim/nvim-lspconfig')
  use("hrsh7th/cmp-nvim-lsp")

  use("jose-elias-alvarez/typescript.nvim") -- additional functionality for typescript server (e.g. rename file & update imports)
  use("onsails/lspkind.nvim") -- vs-code like icons for autocompletion

    -- treesitter configuration
  use({
    "nvim-treesitter/nvim-treesitter",
    run = function()
      local ts_update = require("nvim-treesitter.install").update({ with_sync = true })
      ts_update()
    end,
  })

  if packer_bootstrap then
    require('packer').sync()
  end
end)



