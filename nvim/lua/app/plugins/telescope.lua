local status1, telescope = pcall(require, 'telescope')
if not status1 then
    return
end


local status2, actions = pcall(require, 'telescope.actions')
if not status2 then
    return
end

telescope.setup({
  defaults = {
    mappings = {
      i = {
        ["<C-k>"] = actions.move_selection_previous, -- move to prev result
        ["<C-j>"] = actions.move_selection_next, -- move to next result
        ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist, -- send selected to quickfixlist
      },
    },
  },
})

