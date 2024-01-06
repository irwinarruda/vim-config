local s1, lsp = pcall(require, "lsp-zero")
if not s1 then
	return
end

lsp.preset("recomended")

lsp.set_sign_icons({
	error = "✘",
	warn = "▲",
	hint = "⚑",
	info = "»",
})

local on_attach = function(_, bufnr)
	local opts = { buffer = bufnr, remap = false }
	-- lsp.default_keymaps({buffer = bufnr})
	local keymap = vim.keymap
	keymap.set("n", "<C-,>", function()
		vim.lsp.buf.definition()
	end, opts)
	keymap.set("n", "<C-<>", function()
		vim.lsp.buf.hover()
	end, opts)
	keymap.set("n", "<C-.>", function()
		vim.lsp.buf.code_action()
	end, opts)
	keymap.set("n", "<F2>", function()
		vim.lsp.buf.rename()
	end, opts)
	keymap.set("n", "<leader>vws", function()
		vim.lsp.buf.workspace_symbol()
	end, opts)
	keymap.set("n", "<leader>vd", function()
		vim.diagnostic.open_float()
	end, opts)
	keymap.set("n", "[d", function()
		vim.diagnostic.goto_next()
	end, opts)
	keymap.set("n", "]d", function()
		vim.diagnostic.goto_prev()
	end, opts)
	keymap.set("n", "<leader>vrr", function()
		vim.lsp.buf.references()
	end, opts)
	keymap.set("i", "<C-h>", function()
		vim.lsp.buf.signature_help()
	end, opts)
	keymap.set("n", "<leader>rr", ":TSToolsRenameFile<CR>")
	keymap.set("n", "<leader>rc", ":TSToolsRemoveUnusedImports<CR>")
	keymap.set("n", "<leader>ri", ":TSToolsSortImports<CR>")
end

lsp.on_attach(on_attach)

require("typescript-tools").setup({
	on_attach = on_attach,
	handlers = { lsp.default_setup },
	settings = {
		separate_diagnostic_server = true,
		publish_diagnostic_on = "insert_leave",
		expose_as_code_action = {},
		tsserver_path = nil,
		tsserver_plugins = {},
		tsserver_max_memory = "auto",
		tsserver_format_options = {},
		tsserver_file_preferences = {},
		tsserver_locale = "en",
		complete_function_calls = false,
		include_completions_with_insert_text = true,
		code_lens = "off",
		disable_member_code_lens = true,
		jsx_close_tag = {
			enable = false,
			filetypes = { "javascriptreact", "typescriptreact" },
		},
	},
})

require("mason").setup({})
require("mason-lspconfig").setup({
	ensure_installed = {
		"tsserver",
		"eslint",
		"html",
		"cssls",
		"tailwindcss",
		"rust_analyzer",
		"lua_ls",
	},
	handlers = {
		lsp.default_setup,
		tsserver = nil,
		lua_ls = function()
			local lua_opts = lsp.nvim_lua_ls()
			require("lspconfig").lua_ls.setup(lua_opts)
		end,
		tailwindcss = function()
			local tailwind_opts = {
				settings = {
					tailwindCSS = {
						classAttributes = { "class", "className", "class:list", "classList", "ngClass" },
						lint = {
							cssConflict = "warning",
							invalidApply = "error",
							invalidConfigPath = "error",
							invalidScreen = "error",
							invalidTailwindDirective = "error",
							invalidVariant = "error",
							recommendedVariantOrder = "warning",
						},
						validate = true,
						experimental = {
							classRegex = {
								{
									"tv\\(([^)(]*(?:\\([^)(]*(?:\\([^)(]*(?:\\([^)(]*\\)[^)(]*)*\\)[^)(]*)*\\)[^)(]*)*)\\)",
									"[\"'`](.*?)[\"'`]",
								},
							},
						},
					},
				},
			}
			require("lspconfig").tailwindcss.setup(tailwind_opts)
		end,
	},
})

local conform = require("conform")
conform.setup({
	format_on_save = {
		timeout_ms = 500,
		async = false,
		lsp_fallback = true,
	},
	formatters_by_ft = {
		lua = { "stylua" },
		javascript = { "prettier" },
		typescript = { "prettier" },
		javascriptreact = { "prettier" },
		typescriptreact = { "prettier" },
		svelte = { "prettier" },
		css = { "prettier" },
		html = { "prettier" },
		json = { "prettier" },
		yaml = { "prettier" },
		markdown = { "prettier" },
		graphql = { "prettier" },
		rust = { "rust_analyzer" },
	},
})

vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*",
	callback = function(args)
		conform.format({ bufnr = args.buf })
	end,
})

local keymap = vim.keymap
keymap.set({ "n", "v" }, "<C-s>", function()
	conform.format({
		timeout_ms = 500,
		async = false,
		lsp_fallback = true,
	})
end)

local lint = require("lint")

lint.linters_by_ft = {
	javascript = { "eslint" },
	typescript = { "eslint" },
	javascriptreact = { "eslint" },
	typescriptreact = { "eslint" },
	svelte = { "eslint" },
}

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
	callback = function()
		lint.try_lint(nil, { ignore_errors = true })
	end,
})

keymap.set({ "n", "v" }, "<leader><C-s>", function()
	lint.try_lint(nil, { ignore_errors = true })
end)
