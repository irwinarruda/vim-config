local s1, gitsigns = pcall(require, "gitsigns")
if not s1 then
  return
end

gitsigns.setup({
  current_line_blame = false,
  current_line_blame_opts = {
    virt_text = true,
    virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
    delay = 350,
    ignore_whitespace = false,
    virt_text_priority = 100,
  },
  on_attach = function(bufnr)
    local keymap = vim.keymap
    local opts = { buffer = bufnr, remap = false }
    -- Navigation
    -- keymap.set("n", "]c", function()
    -- 	if vim.wo.diff then
    -- 		return "]c"
    -- 	end
    -- 	vim.schedule(function()
    -- 		gitsigns.next_hunk()
    -- 	end)
    -- 	return "<Ignore>"
    -- end, opts)
    --
    -- keymap.set("n", "[c", function()
    -- 	if vim.wo.diff then
    -- 		return "[c"
    -- 	end
    -- 	vim.schedule(function()
    -- 		gitsigns.prev_hunk()
    -- 	end)
    -- 	return "<Ignore>"
    -- end, opts)

    -- Actions
    -- keymap.set('n', '<leader>hs', gitsigns.stage_hunk, opts)
    keymap.set("n", "<leader>gr", gitsigns.reset_hunk, opts)
    -- keymap.set('v', '<leader>hs', function() gitsigns.stage_hunk {vim.fn.line('.'), vim.fn.line('v')} end, opts)
    -- keymap.set('v', '<leader>hr', function() gitsigns.reset_hunk {vim.fn.line('.'), vim.fn.line('v')} end, opts)
    -- keymap.set('n', '<leader>hS', gitsigns.stage_buffer, opts)
    -- keymap.set('n', '<leader>hu', gitsigns.undo_stage_hunk, opts)
    -- keymap.set('n', '<leader>hR', gitsigns.reset_buffer, opts)
    keymap.set("n", "<leader>gp", function()
      gitsigns.preview_hunk()
      gitsigns.preview_hunk()
    end, opts)
    -- keymap.set("n", "<leader>gb", function()
    -- 	gitsigns.blame_line({ full = true })
    -- end, opts)
    keymap.set("n", "<leader>gb", gitsigns.toggle_current_line_blame, opts)
    -- keymap.set('n', '<leader>hd', gitsigns.diffthis, opts)
    -- keymap.set('n', '<leader>hD', function() gitsigns.diffthis('~') end, opts)
    -- keymap.set('n', '<leader>td', gitsigns.toggle_deleted, opts)
    -- keymap.set({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
  end,
})

vim.cmd([[
  hi! GitSignsCurrentLineBlame guifg=#ffffff
]])
