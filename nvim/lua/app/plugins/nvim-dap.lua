local s1, dap = pcall(require, "dap")
local s2, dapui = pcall(require, "dapui")
local s3, dap_vscode = pcall(require, "dap-vscode-js")
local s4, dap_utils = pcall(require, "dap.utils")

if not s1 or not s2 or not s2 or not s3 or not s4 then
  return
end

dapui.setup()

local keymap = vim.keymap
keymap.set("n", "<leader>de", function()
  dapui.toggle()
end)
keymap.set("n", "<leader>dd", ":DapToggleBreakpoint<CR>", { noremap = true })
keymap.set("n", "<leader>dl", ":DapContinue<CR>", { noremap = true })
keymap.set("n", "<leader>dl", ":DapToggleBreakpoint<CR>", { noremap = true })

vim.fn.sign_define(
  "DapBreakpoint",
  { text = "🔴", texthl = "DapBreakpoint", linehl = "DapBreakpoint", numhl = "DapBreakpoint" }
)

dap_vscode.setup({
  adapters = { "pwa-node", "pwa-chrome", "pwa-msedge", "node-terminal", "pwa-extensionHost" }, -- which adapters to register in nvim-dap
})

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
      name = "Attach",
      processId = dap_utils.pick_process,
      cwd = "${workspaceFolder}",
    },
    {
      type = "pwa-node",
      request = "launch",
      name = "Debug Jest Tests",
      -- trace = true, -- include debugger info
      runtimeExecutable = "node",
      runtimeArgs = {
        "./node_modules/jest/bin/jest.js",
        "--runInBand",
      },
      rootPath = "${workspaceFolder}",
      cwd = "${workspaceFolder}",
      console = "integratedTerminal",
      internalConsoleOptions = "neverOpen",
    },
  }
end
