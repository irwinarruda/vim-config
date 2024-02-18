local s1, dap = pcall(require, "dap")
local s2, dapui = pcall(require, "dapui")
local s3, dapvscode = pcall(require, "dap-vscode-js")
local s4, daptext = pcall(require, "nvim-dap-virtual-text")

if not s1 or not s2 or not s2 or not s3 or not s4 then
  return
end

dapui.setup({
  layouts = {
    {
      elements = {
        {
          id = "scopes",
          size = 0.4,
        },
        {
          id = "watches",
          size = 0.25,
        },
        {
          id = "stacks",
          size = 0.25,
        },
        {
          id = "breakpoints",
          size = 0.10,
        },
      },
      position = "left",
      size = 30,
    },
    {
      elements = {
        {
          id = "repl",
          size = 0.5,
        },
        {
          id = "console",
          size = 0.5,
        },
      },
      position = "bottom",
      size = 7,
    },
  },
})

dapvscode.setup({
  adapters = { "pwa-node", "pwa-chrome", "pwa-msedge", "node-terminal", "pwa-extensionHost" }, -- which adapters to register in nvim-dap
})
daptext.setup()

local keymap = vim.keymap
keymap.set("n", "<leader>de", function()
  dapui.toggle()
end)
keymap.set("n", "<leader>dd", function()
  dap.toggle_breakpoint()
end, { noremap = true })
keymap.set("n", "<leader>dy", function()
  dap.terminate()
end)
keymap.set("n", "<leader>du", function()
  dap.continue()
end)
keymap.set("n", "<leader>dj", function()
  dap.step_over()
end)
keymap.set("n", "<leader>di", function()
  dap.step_into()
end)
keymap.set("n", "<leader>do", function()
  dap.step_out()
end)
keymap.set("n", "<leader>dh", function()
  dap.resttart()
end)

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
