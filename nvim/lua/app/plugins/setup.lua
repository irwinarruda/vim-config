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
	-- Autoclose
	use("m4xshen/autoclose.nvim")
	-- File explorer
	use("nvim-tree/nvim-tree.lua")
	-- Tabs
	use({
		"theprimeagen/harpoon",
		branch = "harpoon2",
		requires = { { "nvim-lua/plenary.nvim" } },
	})
	-- Undo History
	use("mbbill/undotree")
	-- Icons for files
	use("onsails/lspkind.nvim")
	use("kyazdani42/nvim-web-devicons")
	-- Statusline
	use("nvim-lualine/lualine.nvim")
	-- Fuzzy finding w/ telescope
	-- If not working, do :checkhealth telescope to download the other plugins
	-- Needs ripgrep installed
	use("nvim-lua/plenary.nvim")
	use({
		"nvim-telescope/telescope.nvim",
		tag = "0.1.x",
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
	-- Snippets
	use("saadparwaiz1/cmp_luasnip") -- for autocompletion
	use("github/copilot.vim")
	-- LSP
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
		config = function()
			require("typescript-tools").setup({})
		end,
	})
	use("stevearc/conform.nvim")
	use("mfussenegger/nvim-lint")
	use({ "rcarriga/nvim-dap-ui", requires = { "mfussenegger/nvim-dap" } })
	use({ "mxsdev/nvim-dap-vscode-js", requires = { "mfussenegger/nvim-dap" } })
	use("theHamsta/nvim-dap-virtual-text")
	use({
		"microsoft/vscode-js-debug",
		opt = true,
		run = "npm install --legacy-peer-deps && npx gulp vsDebugServerBundle && mv dist out",
	})
	use("folke/neodev.nvim")

	if packer_bootstrap then
		require("packer").sync()
	end
end)
