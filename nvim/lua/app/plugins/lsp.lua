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
      local TYPESCRIPT_LSP = "vtsls"
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
        keymap.set("n", os.motion("lsp_rename"), vim.lsp.buf.rename, opts)
        keymap.set("n", os.motion("lsp_goto_next"), function()
          vim.diagnostic.goto_next()
          vim.cmd.normal("zz")
        end, opts)
        keymap.set("n", os.motion("lsp_goto_prev"), function()
          vim.diagnostic.goto_prev()
          vim.cmd.normal("zz")
        end, opts)
        if TYPESCRIPT_LSP == "typescript-tools" then
          keymap.set("n", os.motion("lsp_ts_rename_file"), ":TSToolsRenameFile<CR>", opts)
          keymap.set("n", os.motion("lsp_ts_remove_imports"), ":TSToolsRemoveUnusedImports<CR>", opts)
          keymap.set("n", os.motion("lsp_ts_sort_imports"), ":TSToolsSortImports<CR>", opts)
        elseif TYPESCRIPT_LSP == "vtsls" then
          keymap.set("n", os.motion("lsp_ts_rename_file"), function()
            require("vtsls").commands.rename_file(opts.buffer)
          end, opts)
          keymap.set("n", os.motion("lsp_ts_remove_imports"), function()
            require("vtsls").commands.remove_unused_imports(opts.buffer)
          end, opts)
          keymap.set("n", os.motion("lsp_ts_sort_imports"), function()
            require("vtsls").commands.sort_imports(opts.buffer)
          end, opts)
          keymap.set("n", os.motion("lsp_ts_select_version"), function()
            require("vtsls").commands.select_ts_version(opts.buffer)
          end, opts)
        end
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
          vtsls = function() end,
          ts_ls = function()
            if TYPESCRIPT_LSP == "typescript-tools" then
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
            elseif TYPESCRIPT_LSP == "vtsls" then
              require("lspconfig").vtsls.setup({
                settings = {
                  typescript = {
                    inlayHints = {
                      parameterNames = { enabled = "literals" },
                      parameterTypes = { enabled = true },
                      variableTypes = { enabled = true },
                      propertyDeclarationTypes = { enabled = true },
                      functionLikeReturnTypes = { enabled = true },
                      enumMemberValues = { enabled = true },
                    },
                  },
                },
              })
            end
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
                  experimental = {
                    classRegex = {
                      { "([\"'`][^\"'`]*.*?[\"'`])", "[\"'`]([^\"'`]*).*?[\"'`]" },
                    },
                  },
                },
              },
            })
          end,
          volar = function()
            -- local path = require("mason-registry").get_package("typescript-language-server"):get_install_path()
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
                  EnableEditorConfigSupport = true,
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

      local current_bufnr = -1
      local is_eslint_available = false
      local function javascript_format(bufnr)
        if current_bufnr == bufnr then
          if is_eslint_available then
            return { "prettierd", "eslint_d" }
          end
          return { "prettierd" }
        end
        current_bufnr = bufnr
        is_eslint_available = false
        local clients = vim.lsp.get_clients({ bufnr = bufnr })
        for _, client in ipairs(clients) do
          if client.name == "eslint" then
            is_eslint_available = true
            return { "prettierd", "eslint_d" }
          end
        end
        return { "prettierd" }
      end

      conform.setup({
        format_on_save = {
          timeout_ms = 1000,
          lsp_fallback = true,
        },
        log_level = vim.log.levels.ERROR,
        formatters_by_ft = {
          lua = { "stylua" },
          javascript = javascript_format,
          typescript = javascript_format,
          javascriptreact = javascript_format,
          typescriptreact = javascript_format,
          svelte = { "prettierd", "prettier", stop_after_first = true },
          vue = { "prettierd", "prettier", stop_after_first = true },
          css = { "prettierd", "prettier", stop_after_first = true },
          html = { "prettierd", "prettier", stop_after_first = true },
          json = { "prettierd", "prettier", stop_after_first = true },
          yaml = { "prettierd", "prettier", stop_after_first = true },
          markdown = { "prettierd", "prettier", stop_after_first = true },
          graphql = { "prettierd", "prettier", stop_after_first = true },
          rust = { "rust_analyzer" },
          go = { "gofmt", "goimports" },
          nginx = { "nginxfmt" },
        },
        formatters = {
          -- Need to install manually
          nginxfmt = {
            prepend_args = { "-i", "2" },
          },
        },
      })

      local keymap = vim.keymap
      keymap.set({ "n", "v" }, "<C-s>", function()
        conform.format({
          timeout_ms = 1000,
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
        svelte = { "eslint" },
        vue = { "eslint" },
      }
      local keymap = vim.keymap
      keymap.set({ "n", "v" }, "<leader><C-s>", function()
        lint.try_lint(nil, { ignore_errors = true })
      end)
    end,
  },
}
