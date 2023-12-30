local s1, dap = pcall(require, "dap")
local s2, dapui = pcall(require, "dapui")
local s3, neodev = pcall(require, "neodev")
local s4, dap_vscode = pcall(require, "dap-vscode-js")
local s5, dap_utils = pcall(require, "dat.utils")

if not s1 or not s2 or not s2 or not s3 or not s4 or not s5 then
	return
end

neodev.setup({
	library = { plugins = { "nvim-dap-ui" }, types = true },
})

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
	-- node_path = "node", -- Path of node executable. Defaults to $NODE_PATH, and then "node"
	-- debugger_path = "(runtimedir)/site/pack/packer/opt/vscode-js-debug", -- Path to vscode-js-debug installation.
	-- debugger_cmd = { "js-debug-adapter" }, -- Command to use to launch the debug server. Takes precedence over `node_path` and `debugger_path`.
	adapters = { "pwa-node", "pwa-chrome", "pwa-msedge", "node-terminal", "pwa-extensionHost" }, -- which adapters to register in nvim-dap
	-- log_file_path = "(stdpath cache)/dap_vscode_js.log" -- Path for file logging
	-- log_file_level = false -- Logging level for output to file. Set to false to disable file logging.
	-- log_console_level = vim.log.levels.ERROR -- Logging level for output to console. Set to false to disable console output.
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
