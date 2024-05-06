return {
  {
    "vonheikemen/lsp-zero.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "neovim/nvim-lspconfig",
      "hrsh7th/nvim-cmp",
      "hrsh7th/cmp-nvim-lsp",
      "L3MON4D3/LuaSnip",
      "pmizio/typescript-tools.nvim",
    },
    branch = "v3.x",
    config = function()
      local lsp = require("lsp-zero")
      lsp.preset("recomended")
      lsp.set_sign_icons({
        error = "✘",
        warn = "▲",
        hint = "⚑",
        info = "»",
      })

      local on_attach = function(_, bufnr)
        local opts = { buffer = bufnr, remap = false }
        local os = require("app.plugins.nvim-os-persist")
        require("app.plugins.telescope").telescope_lsp_keymaps(opts)

        local keymap = vim.keymap
        keymap.set("n", os.motion("lsp_hover_diagnostic"), function()
          vim.diagnostic.open_float()
          vim.diagnostic.open_float()
        end, opts)
        keymap.set("n", os.motion("lsp_hover"), function()
          vim.lsp.buf.hover()
          vim.lsp.buf.hover()
        end, opts)
        -- keymap.set("n", os.motion("lsp_code_action"), function()
        --   vim.lsp.buf.code_action()
        -- end, opts)
        keymap.set("n", os.motion("lsp_code_action"), "<cmd>Lspsaga code_action<cr>", opts)
        keymap.set("n", os.motion("lsp_rename"), function()
          vim.lsp.buf.rename()
        end, opts)
        keymap.set("n", os.motion("lsp_workspace_symbol"), function()
          vim.lsp.buf.workspace_symbol("")
        end, opts)
        keymap.set("n", os.motion("lsp_goto_next"), function()
          vim.diagnostic.goto_next()
        end, opts)
        keymap.set("n", os.motion("lsp_goto_prev"), function()
          vim.diagnostic.goto_prev()
        end, opts)
        keymap.set("i", os.motion("lsp_signature_help"), function()
          vim.lsp.buf.signature_help()
        end, opts)
        keymap.set("n", os.motion("lsp_ts_rename_file"), ":TSToolsRenameFile<CR>", opts)
        keymap.set("n", os.motion("lsp_ts_remove_imports"), ":TSToolsRemoveUnusedImports<CR>", opts)
        keymap.set("n", os.motion("lsp_ts_sort_imports"), ":TSToolsSortImports<CR>", opts)
      end

      lsp.on_attach(on_attach)

      require("mason").setup({})
      require("mason-lspconfig").setup({
        ensure_installed = {
          "clangd",
          "dockerls",
          "eslint",
          "html",
          "cssls",
          "tailwindcss",
          "tsserver",
          "svelte",
          "volar",
          "vuels",
          "jsonls",
          "lua_ls",
          "rust_analyzer",
          "gopls",
          "templ",
          "pylsp",
        },
        handlers = {
          lsp.default_setup,
          tsserver = function()
            -- Use for project wide diagnostics https://github.com/dmmulroy/tsc.nvim
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
          end,
          jsonls = function()
            require("lspconfig").jsonls.setup({
              on_attach = on_attach,
              handlers = { lsp.default_setup },
              settings = {
                json = {
                  schemas = {
                    {
                      fileMatch = { "package.json" },
                      url = "https://json.schemastore.org/package.json",
                    },
                    {
                      fileMatch = { "tsconfig*.json" },
                      url = "https://json.schemastore.org/tsconfig.json",
                    },
                    {
                      fileMatch = { "tauri.conf.json" },
                      url = "https://raw.githubusercontent.com/tauri-apps/tauri/dev/tooling/cli/schema.json",
                    },
                    {
                      fileMatch = { ".prettierrc", ".prettierrc.json", ".prettierrc.json5" },
                      url = "https://json.schemastore.org/prettierrc",
                    },
                    {
                      fileMatch = { ".eslintrc.json" },
                      url = "https://json.schemastore.org/eslintrc",
                    },
                  },
                },
              },
            })
          end,
          lua_ls = function()
            require("lspconfig").lua_ls.setup(lsp.nvim_lua_ls())
          end,
          tailwindcss = function()
            require("lspconfig").tailwindcss.setup({
              on_attach = on_attach,
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
            })
          end,
          clangd = function()
            local default_config = require("lspconfig.server_configurations.clangd").default_config
            default_config.capabilities.offsetEncoding = "utf-8"
            require("lspconfig").clangd.setup(default_config)
          end,
        },
      })
    end,
  },
  {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
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
          vue = { "prettier" },
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
        group = vim.api.nvim_create_augroup("ConformFormatOnSave", { clear = false }),
        desc = "Conform format on save",
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
    end,
  },
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lint = require("lint")
      lint.linters_by_ft = {
        javascript = { "eslint" },
        typescript = { "eslint" },
        javascriptreact = { "eslint" },
        typescriptreact = { "eslint" },
        svelte = { "eslint" },
        vue = { "eslint" },
      }

      vim.api.nvim_create_autocmd({ "BufWritePost" }, {
        group = vim.api.nvim_create_augroup("LintOnSave", { clear = false }),
        desc = "Lint on save",
        callback = function()
          lint.try_lint(nil, { ignore_errors = true })
        end,
      })

      local keymap = vim.keymap
      keymap.set({ "n", "v" }, "<leader><C-s>", function()
        lint.try_lint(nil, { ignore_errors = true })
      end)
    end,
  },
}
