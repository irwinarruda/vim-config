return {
  "goolord/alpha-nvim",
  event = "VimEnter",
  config = function()
    local alpha = require("alpha")
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
      dashboard.button("e", "  > New File", "<cmd>ene<CR>"),
      dashboard.button("<Space>e", "  > Toggle file explorer", "<cmd>NvimTreeToggle<CR>"),
      dashboard.button("<Space>fo", "󰱼  > Find File", "<cmd>Telescope find_files<CR>"),
      dashboard.button("<Space>ff", "  > Find Word", "<cmd>Telescope live_grep<CR>"),
      dashboard.button("u", "󰚰  > Update packages", "<cmd>Lazy<CR>"),
      dashboard.button("q", "  > Quit NVIM", "<cmd>qa<CR>"),
    }

    alpha.setup(dashboard.opts)

    vim.cmd([[autocmd FileType alpha setlocal nofoldenable]])
  end,
}
