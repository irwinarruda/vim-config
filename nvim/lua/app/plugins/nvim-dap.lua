-- vscode-js-debug's DAP server, installed by Mason as js-debug-adapter
local JS_ADAPTERS = { "pwa-node", "pwa-chrome", "pwa-msedge", "node-terminal", "pwa-extensionHost" }

return {
  "mfussenegger/nvim-dap",
  event = "VeryLazy",
  dependencies = {
    "rcarriga/nvim-dap-ui",
    "nvim-neotest/nvim-nio",
    "theHamsta/nvim-dap-virtual-text",
  },
  config = function()
    local dap = require("dap")
    local dapui = require("dapui")

    dapui.setup({
      layouts = {
        {
          elements = {
            { id = "scopes", size = 0.4 },
            { id = "watches", size = 0.25 },
            { id = "stacks", size = 0.25 },
            { id = "breakpoints", size = 0.10 },
          },
          position = "left",
          size = 30,
        },
        {
          elements = {
            { id = "repl", size = 0.5 },
            { id = "console", size = 0.5 },
          },
          position = "bottom",
          size = 7,
        },
      },
    })
    require("nvim-dap-virtual-text").setup()

    for _, adapter in ipairs(JS_ADAPTERS) do
      dap.adapters[adapter] = {
        type = "server",
        host = "localhost",
        port = "${port}",
        executable = {
          command = "js-debug-adapter",
          args = { "${port}" },
        },
      }
    end

    local keymap = vim.keymap
    keymap.set("n", "<leader>de", dapui.toggle)
    keymap.set("n", "<leader>dd", dap.toggle_breakpoint)
    keymap.set("n", "<leader>dy", dap.terminate)
    keymap.set("n", "<leader>du", dap.continue)
    keymap.set("n", "<leader>dj", dap.step_over)
    keymap.set("n", "<leader>di", dap.step_into)
    keymap.set("n", "<leader>do", dap.step_out)
    keymap.set("n", "<leader>dh", dap.restart)

    vim.fn.sign_define(
      "DapBreakpoint",
      { text = "🔴", texthl = "DapBreakpoint", linehl = "DapBreakpoint", numhl = "DapBreakpoint" }
    )
    vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })

    dap.listeners.before.attach.dapui_config = function()
      dapui.open()
    end
    dap.listeners.before.launch.dapui_config = function()
      dapui.open()
    end

    for _, language in ipairs({ "typescript", "javascript", "javascriptreact", "typescriptreact" }) do
      dap.configurations[language] = {
        {
          type = "pwa-node",
          request = "launch",
          name = "Launch file",
          program = "${file}",
          cwd = "${workspaceFolder}",
        },
        {
          type = "pwa-node",
          request = "attach",
          name = "Attach to process",
          restart = true,
          -- processId = daputils.pick_process,
          sourceMaps = true,
          skipFiles = { "<node_internals>/**" },
          cwd = "${workspaceFolder}/**/*.js",
        },
      }
    end
  end,
}
