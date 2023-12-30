local s1, nvimtree = pcall(require, "nvim-tree")
local s2, nvimtreesitter = pcall(require, "nvim-treesitter.configs")

if not s1 or not s2 then
	return
end

vim.g.loaded = 1
vim.g.loaded_netrwPlugin = 1
nvimtree.setup()
nvimtreesitter.setup({
	ensure_installed = {
		"c",
		"lua",
		"vim",
		"vimdoc",
		"typescript",
		"javascript",
		"svelte",
		"vue",
		"java",
		"json",
		"xml",
	},
	sync_install = false,
	highlight = {
		enable = true,
		additional_vim_regex_highlighting = false,
	},
})

local keymap = vim.keymap
-- nvim-tree
keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>") -- open close file explorer
