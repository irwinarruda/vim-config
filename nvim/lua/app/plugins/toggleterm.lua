return {
  "akinsho/toggleterm.nvim",
  event = "VeryLazy",
  init = function()
    if vim.loop.os_uname().sysname == "Windows_NT" then
      vim.opt.shell = "pwsh"
      vim.opt.shellcmdflag =
        "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;"
      vim.opt.shellredir = "-RedirectStandardOutput %s -NoNewWindow -Wait"
      vim.opt.shellpipe = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode"
      vim.opt.shellquote = ""
      vim.opt.shellxquote = ""
    end
  end,
  config = function()
    local toggleterm = require("toggleterm")
    local workspace = require("app.core.workspace")
    local cwd = vim.fn.getcwd()
    local repos = not workspace.is_inside_git_repo(cwd) and workspace.find_git_repos(cwd) or {}
    local is_workspace_mode = #repos > 0

    toggleterm.setup({
      open_mapping = not is_workspace_mode and "<leader>t" or false,
      direction = "float",
      start_in_insert = false,
      hide_numbers = false,
      insert_mappings = false,
      terminal_mappings = false,
    })

    if is_workspace_mode then
      local Terminal = require("toggleterm.terminal").Terminal
      local workspace_terms = {}
      for i, repo in ipairs(repos) do
        workspace_terms[i] = Terminal:new({
          id = i,
          dir = repo.path,
          direction = "float",
          display_name = repo.name,
          start_in_insert = false,
          hidden = true,
        })
      end

      vim.keymap.set("n", "<leader>t", function()
        local count = vim.v.count1
        if workspace_terms[count] then
          workspace_terms[count]:toggle()
        else
          vim.cmd(count .. "ToggleTerm direction=float")
        end
      end, { silent = true, desc = "Toggle workspace terminal" })
    end

    vim.keymap.set("t", "<C-q>", "<cmd>ToggleTerm<cr>", { silent = true })
  end,
}
