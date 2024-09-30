return {
  {
    "vonheikemen/lsp-zero.nvim",
    event = "VeryLazy",
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
          vim.defer_fn(function()
            vim.lsp.buf.hover()
          end, 80)
        end, opts)
        keymap.set("n", os.motion("lsp_code_action"), function()
          require("lspsaga.command").load_command("code_action")
        end, opts)
        keymap.set("n", os.motion("lsp_rename"), function()
          vim.lsp.buf.rename()
        end, opts)
        keymap.set("n", os.motion("lsp_workspace_symbol"), function()
          vim.lsp.buf.workspace_symbol("")
        end, opts)
        keymap.set("n", os.motion("lsp_goto_next"), function()
          vim.diagnostic.goto_next()
          vim.cmd.normal("zz")
        end, opts)
        keymap.set("n", os.motion("lsp_goto_prev"), function()
          vim.diagnostic.goto_prev()
          vim.cmd.normal("zz")
        end, opts)
        keymap.set("i", os.motion("lsp_signature_help"), function()
          vim.lsp.buf.signature_help()
        end, opts)
        keymap.set("n", os.motion("lsp_ts_rename_file"), ":TSToolsRenameFile<CR>", opts)
        keymap.set("n", os.motion("lsp_ts_remove_imports"), ":TSToolsRemoveUnusedImports<CR>", opts)
        keymap.set("n", os.motion("lsp_ts_sort_imports"), ":TSToolsSortImports<CR>", opts)
      end

      lsp.on_attach(on_attach)

      vim.keymap.set("n", "<leader>h", function()
        ---@diagnostic disable-next-line: missing-parameter
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
      end, { noremap = true })

      require("mason").setup({})
      require("mason-lspconfig").setup({
        handlers = {
          lsp.default_setup,
          ts_ls = function()
            -- Use for project wide diagnostics https://github.com/dmmulroy/tsc.nvim
            require("typescript-tools").setup({
              on_attach = on_attach,
              handlers = { lsp.default_setup },
              settings = {
                separate_diagnostic_server = true,
                publish_diagnostic_on = "insert_leave",
                expose_as_code_action = "all",
                tsserver_path = nil,
                tsserver_plugins = {},
                tsserver_max_memory = "auto",
                tsserver_format_options = {},
                tsserver_locale = "en",
                complete_function_calls = false,
                include_completions_with_insert_text = true,
                code_lens = "off",
                disable_member_code_lens = false,
                jsx_close_tag = {
                  enable = false,
                  filetypes = { "javascriptreact", "typescriptreact" },
                },
                tsserver_file_preferences = {
                  includeInlayEnumMemberValueHints = false,
                  includeInlayFunctionLikeReturnTypeHints = true,
                  includeInlayFunctionParameterTypeHints = true,
                  includeInlayParameterNameHints = "all",
                  includeInlayParameterNameHintsWhenArgumentMatchesName = true,
                  includeInlayPropertyDeclarationTypeHints = true,
                  includeInlayVariableTypeHints = false,
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
                    {
                      fileMatch = { ".babelrc.json", ".babelrc.json5" },
                      url = "https://json.schemastore.org/babelrc",
                    },
                  },
                },
              },
            })
          end,
          lua_ls = function()
            local lua_config = lsp.nvim_lua_ls()
            lua_config.settings.Lua.hint = { enable = true }
            require("lspconfig").lua_ls.setup(lua_config)
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
          volar = function()
            -- local path = require("mason-registry").get_package("typescript-language-server"):get_install_path()
            --   .. "/node_modules/typescript/lib"
            require("lspconfig").volar.setup({
              on_attach = on_attach,
              handlers = { lsp.default_setup },
              filetypes = { "vue" },
              init_options = {
                vue = {
                  hybridMode = false,
                },
              },
            })
          end,
          clangd = function()
            local default_config = require("lspconfig.server_configurations.clangd").default_config
            default_config.capabilities.offsetEncoding = "utf-8"
            require("lspconfig").clangd.setup(default_config)
          end,
          omnisharp = function()
            require("lspconfig").omnisharp.setup({
              handlers = {
                lsp.default_setup,
                ["textDocument/definition"] = require("omnisharp_extended").definition_handler,
                ["textDocument/typeDefinition"] = require("omnisharp_extended").type_definition_handler,
                ["textDocument/references"] = require("omnisharp_extended").references_handler,
                ["textDocument/implementation"] = require("omnisharp_extended").implementation_handler,
              },
              settings = {
                FormattingOptions = {
                  NewLinesForBracesInLambdaExpressionBody = false,
                  NewLinesForBracesInAnonymousMethods = false,
                  NewLinesForBracesInAnonymousTypes = false,
                  NewLinesForBracesInControlBlocks = false,
                  NewLinesForBracesInTypes = false,
                  NewLinesForBracesInMethods = false,
                  NewLinesForBracesInProperties = false,
                  NewLinesForBracesInObjectCollectionArrayInitializers = false,
                  NewLinesForBracesInAccessors = false,
                  NewLineForElse = false,
                  NewLineForCatch = false,
                  NewLineForFinally = false,
                  EnableEditorConfigSupport = false,
                  OrganizeImports = true,
                },
                MsBuild = {
                  LoadProjectsOnDemand = nil,
                },
                RoslynExtensionsOptions = {
                  EnableDecompilationSupport = true,
                  EnableImportCompletion = true,
                  EnableAnalyzersSupport = nil,
                  AnalyzeOpenDocumentsOnly = nil,
                },
                Sdk = {
                  IncludePrereleases = true,
                },
              },
            })
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
          lsp_fallback = true,
        },
        log_level = vim.log.levels.ERROR,
        formatters_by_ft = {
          lua = { "stylua" },
          javascript = { "prettier", stop_after_first = true },
          typescript = { "prettier", stop_after_first = true },
          javascriptreact = { "prettier", stop_after_first = true },
          typescriptreact = { "prettier", stop_after_first = true },
          svelte = { "prettier", stop_after_first = true },
          vue = { "prettier", stop_after_first = true },
          css = { "prettier", stop_after_first = true },
          html = { "prettier", stop_after_first = true },
          json = { "prettier", stop_after_first = true },
          yaml = { "prettier", stop_after_first = true },
          markdown = { "prettier", stop_after_first = true },
          graphql = { "prettier", stop_after_first = true },
          rust = { "rust_analyzer" },
          go = { "gofmt" },
        },
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
