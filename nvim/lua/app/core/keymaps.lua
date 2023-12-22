vim.g.mapleader = ' '

local keymap = vim.keymap

keymap.set('n', '<leader>+', '<C-a>')
keymap.set('n', '<leader>-', '<C-x>')
keymap.set('n', 'x', '_x')
keymap.set('n', '<leader>p', '\"_dP', {noremap = true}) -- paste without copying
keymap.set('v', '<leader>p', '\"_dP', {noremap = true}) -- paste without copying

keymap.set('n', '<leader>sl', '<C-w>v') -- split window right
keymap.set('n', '<leader>sj', '<C-w>s') -- split window down
keymap.set('n', '<leader>se', '<C-w>=') -- make split windows equal width & height
keymap.set('n', '<leader>sc', ':close<CR>') -- close current split window
-- vim-maximizer
keymap.set('n', '<leader>sm', ':MaximizerToggle<CR>')

keymap.set('n', '<leader>tn', ':tabnew<CR>') -- open new tab
keymap.set('n', '<leader>tc', ':tabclose<CR>') -- close current tab
keymap.set('n', '<leader>tl', ':tabn<CR>') --  go to next tab
keymap.set('n', '<leader>th', ':tabp< R>') --  go to previous tab

-- nvim-tree
keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>') -- open close terminal

-- telescope
keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>") -- find files within current working directory, respects .gitignore
keymap.set("n", "<leader>fs", "<cmd>Telescope live_grep<cr>") -- find string in current working directory as you type
keymap.set("n", "<leader>fc", "<cmd>Telescope grep_string<cr>") -- find string under cursor in current working directory
keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr>") -- list open buffers in current neovim instance
keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<cr>") -- list available help tags

vim.g.VM_maps = {
    ['Find Under'] = 'gb',
    ['Find Subword Under'] = 'gb',
}

