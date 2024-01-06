local s1, nvimtree = pcall(require, "nvim-tree")

if not s1 then
	return
end

vim.g.loaded = 1
vim.g.loaded_netrwPlugin = 1
nvimtree.setup({
	git = {
		ignore = false,
	},
})

vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>")
