local s1, _ = pcall(vim.cmd, "packadd! dracula_pro")
if not s1 then
	return
end
-- dracula_pro_blade
-- dracula_pro_buffy
-- dracula_pro_lincoln
-- dracula_pro_morbius
-- dracula_pro_van_helsing
vim.cmd("syntax enable")
vim.cmd("let g:dracula_colorterm = 0")
vim.cmd("colorscheme dracula_pro")
vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
