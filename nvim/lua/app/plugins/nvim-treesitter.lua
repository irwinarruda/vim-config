local s1, nvimtreesitter = pcall(require, "nvim-treesitter.configs")

if not s1 then
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

require("nvim-ts-autotag").setup()
