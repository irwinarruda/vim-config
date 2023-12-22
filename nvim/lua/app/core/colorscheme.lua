-- Start Config Dracula PRO
local status, _ = pcall(vim.cmd, 'packadd dracula_pro')
if not status then
    print('Dracula theme not installed')
    return
end
vim.cmd('syntax enable')
vim.g.dracula_colorterm = 0
vim.cmd('colorscheme dracula_pro_buffy')
-- End Config Dracula PRO
