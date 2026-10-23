return {
  "goolord/alpha-nvim",
  event = "VimEnter",
  config = function()
    local dashboard = require("alpha.themes.dashboard")

    dashboard.section.header.val = {
      "██╗██████╗ ██╗   ██╗██╗███╗   ███╗ ",
      "██║██╔══██╗██║   ██║██║████╗ ████║ ",
      "██║██████╔╝██║   ██║██║██╔████╔██║ ",
      "██║██╔══██╗╚██╗ ██╔╝██║██║╚██╔╝██║ ",
      "██║██║  ██║ ╚████╔╝ ██║██║ ╚═╝ ██║ ",
      "╚═╝╚═╝  ╚═╝  ╚═══╝  ╚═╝╚═╝     ╚═╝ ",
    }

    dashboard.section.buttons.val = {
      dashboard.button("e", "  > New File", "<cmd>ene<CR>"),
      dashboard.button("<Space>e", "  > Toggle file explorer", "<cmd>NvimTreeToggle<CR>"),
      dashboard.button("<Space>fo", "󰱼  > Find File", "<cmd>Telescope find_files<CR>"),
      dashboard.button("<Space>ff", "  > Find Word", "<cmd>Telescope live_grep<CR>"),
      dashboard.button("u", "󰚰  > Update packages", "<cmd>Lazy<CR>"),
      dashboard.button("q", "  > Quit NVIM", "<cmd>qa<CR>"),
    }

    require("alpha").setup(dashboard.opts)

    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("AlphaNoFold", { clear = true }),
      pattern = "alpha",
      command = "setlocal nofoldenable",
    })
  end,
}
