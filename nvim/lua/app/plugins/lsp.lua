local BIOME_CONFIG_FILES = {
  "biome.json",
  "biome.jsonc",
  ".biome.json",
  ".biome.jsonc",
}

local ESLINT_CONFIG_FILES = {
  ".eslintrc",
  ".eslintrc.js",
  ".eslintrc.cjs",
  ".eslintrc.yaml",
  ".eslintrc.yml",
  ".eslintrc.json",
  "eslint.config.js",
  "eslint.config.mjs",
  "eslint.config.cjs",
  "eslint.config.ts",
  "eslint.config.mts",
  "eslint.config.cts",
}

local PACKAGE_JSON_FILES = { "package.json", "package.json5" }

local PROJECT_ROOT_MARKERS = {
  "package-lock.json",
  "yarn.lock",
  "pnpm-lock.yaml",
  "bun.lockb",
  "bun.lock",
  "deno.lock",
  ".git",
}

local function get_project_root(bufnr)
  return vim.fs.root(bufnr, PROJECT_ROOT_MARKERS) or vim.fn.getcwd()
end

local function package_json_has_field(filename, field, stop_dir)
  local package_json_files = vim.fs.find(PACKAGE_JSON_FILES, {
    path = filename,
    upward = true,
    type = "file",
    stop = stop_dir,
  })

  for _, package_json_file in ipairs(package_json_files) do
    local file = io.open(package_json_file, "r")
    if file then
      local content = file:read("*a")
      file:close()
      if content and content:find(field, 1, true) then
        return true
      end
    end
  end

  return false
end

local function package_json_root_with_field(filename, field, stop_dir)
  local package_json_files = vim.fs.find(PACKAGE_JSON_FILES, {
    path = filename,
    upward = true,
    type = "file",
    stop = stop_dir,
  })

  for _, package_json_file in ipairs(package_json_files) do
    local file = io.open(package_json_file, "r")
    if file then
      local content = file:read("*a")
      file:close()
      if content and content:find(field, 1, true) then
        return vim.fs.dirname(package_json_file)
      end
    end
  end

  return nil
end

local function has_project_file(filename, files, stop_dir)
  return vim.fs.find(files, {
    path = filename,
    upward = true,
    type = "file",
    limit = 1,
    stop = stop_dir,
  })[1] ~= nil
end

local function project_file_root(filename, files, stop_dir)
  local matched_file = vim.fs.find(files, {
    path = filename,
    upward = true,
    type = "file",
    limit = 1,
    stop = stop_dir,
  })[1]

  return matched_file and vim.fs.dirname(matched_file) or nil
end

local function mason_bin(name)
  local bin = vim.fs.joinpath(vim.fn.stdpath("data"), "mason", "bin", name)
  return vim.fn.executable(bin) == 1 and bin or name
end

local function uses_biome(bufnr)
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
    if client.name == "biome" then
      return true
    end
  end

  local filename = vim.api.nvim_buf_get_name(bufnr)
  if filename == "" then
    return false
  end

  local project_root = get_project_root(bufnr)
  local stop_dir = vim.fs.dirname(project_root)

  return has_project_file(filename, BIOME_CONFIG_FILES, stop_dir)
    or package_json_has_field(filename, "@biomejs/biome", stop_dir)
end

local function uses_eslint(bufnr)
  local filename = vim.api.nvim_buf_get_name(bufnr)
  if filename == "" then
    return false
  end

  if vim.fs.root(bufnr, { "deno.json", "deno.jsonc", "deno.lock" }) then
    return false
  end

  local project_root = get_project_root(bufnr)
  local stop_dir = vim.fs.dirname(project_root)
  local eslint_root = project_file_root(filename, ESLINT_CONFIG_FILES, stop_dir)
    or package_json_root_with_field(filename, "eslintConfig", stop_dir)

  if not eslint_root then
    return false
  end

  local biome_root = project_file_root(filename, BIOME_CONFIG_FILES, stop_dir)
    or package_json_root_with_field(filename, "@biomejs/biome", stop_dir)

  return not biome_root or #eslint_root >= #biome_root
end

return {
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {},
  },
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "folke/lazydev.nvim",
      "mason-org/mason.nvim",
      "mason-org/mason-lspconfig.nvim",
      "nvim-os-persist",
      "hrsh7th/nvim-cmp",
      "hrsh7th/cmp-nvim-lsp",
      "L3MON4D3/LuaSnip",
      "pmizio/typescript-tools.nvim",
      "yioneko/nvim-vtsls",
      {
        "seblyng/roslyn.nvim",
        commit = "f2ec6ee6384c3b611ddc817b9e78b20cd0334bbb",
        opts = {
          broad_search = true,
          filewatching = "roslyn",
          silent = true,
        },
      },
    },
    config = function()
      local TYPESCRIPT_LSP = require("app.core.typescript-lsp").get()
      local ts_actions = require("app.core.typescript-actions")
      local roslyn_codelens_group = vim.api.nvim_create_augroup("app_roslyn_codelens", { clear = true })
      local function refresh_roslyn_codelens(bufnr)
        pcall(vim.lsp.codelens.refresh, { bufnr = bufnr })
      end

      local on_attach = function(_, bufnr)
        local opts = { buffer = bufnr, remap = false }
        local os = require("nvim-os-persist")
        require("app.core.lsp-keymaps").setup(opts)

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
          vim.diagnostic.jump({ count = 1 })
          vim.cmd.normal("zz")
        end, opts)
        keymap.set("n", os.motion("lsp_goto_prev"), function()
          vim.diagnostic.jump({ count = -1 })
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
        elseif TYPESCRIPT_LSP == "tsgo" then
          keymap.set("n", os.motion("lsp_ts_rename_file"), function()
            ts_actions.rename_file({ bufnr = opts.buffer, client_name = "tsgo" })
          end, opts)
          keymap.set("n", os.motion("lsp_ts_remove_imports"), function()
            ts_actions.apply_source_action("source.removeUnusedImports", { bufnr = opts.buffer, client_name = "tsgo" })
          end, opts)
          keymap.set("n", os.motion("lsp_ts_sort_imports"), function()
            ts_actions.apply_source_action("source.sortImports", { bufnr = opts.buffer, client_name = "tsgo" })
          end, opts)
        end
        vim.keymap.set("n", "<leader>h", function()
          ---@diagnostic disable-next-line: missing-parameter
          vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
        end, { noremap = true })
      end

      if TYPESCRIPT_LSP == "typescript-tools" then
        require("typescript-tools").setup({
          on_attach = on_attach,
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
        vim.lsp.config("vtsls", {
          on_attach = on_attach,
        })
        vim.lsp.enable("vtsls")
      elseif TYPESCRIPT_LSP == "tsgo" then
        vim.lsp.config("tsgo", {
          on_attach = on_attach,
          cmd = function(dispatchers)
            return vim.lsp.rpc.start({ mason_bin("tsgo"), "--lsp", "--stdio" }, dispatchers)
          end,
        })
        vim.lsp.enable("tsgo")
      end
      vim.lsp.config("jsonls", {
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
      vim.lsp.config("roslyn", {
        on_attach = function(client, bufnr)
          on_attach(client, bufnr)

          if client.server_capabilities.codeLensProvider then
            vim.api.nvim_clear_autocmds({ group = roslyn_codelens_group, buffer = bufnr })
            vim.api.nvim_create_autocmd({ "BufEnter", "InsertLeave", "BufWritePost" }, {
              group = roslyn_codelens_group,
              buffer = bufnr,
              callback = function(event)
                refresh_roslyn_codelens(event.buf)
              end,
            })
            refresh_roslyn_codelens(bufnr)
          end
        end,
        settings = {
          ["csharp|background_analysis"] = {
            dotnet_analyzer_diagnostics_scope = "fullSolution",
            dotnet_compiler_diagnostics_scope = "fullSolution",
          },
          ["csharp|code_lens"] = {
            dotnet_enable_references_code_lens = true,
            dotnet_enable_tests_code_lens = true,
          },
          ["csharp|completion"] = {
            dotnet_provide_regex_completions = true,
            dotnet_show_completion_items_from_unimported_namespaces = true,
            dotnet_show_name_completion_suggestions = true,
          },
          ["csharp|formatting"] = {
            dotnet_organize_imports_on_format = true,
          },
          ["csharp|inlay_hints"] = {
            csharp_enable_inlay_hints_for_implicit_object_creation = true,
            csharp_enable_inlay_hints_for_implicit_variable_types = true,
            csharp_enable_inlay_hints_for_lambda_parameter_types = true,
            csharp_enable_inlay_hints_for_types = true,
            dotnet_enable_inlay_hints_for_indexer_parameters = true,
            dotnet_enable_inlay_hints_for_literal_parameters = true,
            dotnet_enable_inlay_hints_for_object_creation_parameters = true,
            dotnet_enable_inlay_hints_for_other_parameters = true,
            dotnet_enable_inlay_hints_for_parameters = true,
            dotnet_suppress_inlay_hints_for_parameters_that_differ_only_by_suffix = true,
            dotnet_suppress_inlay_hints_for_parameters_that_match_argument_name = true,
            dotnet_suppress_inlay_hints_for_parameters_that_match_method_intent = true,
          },
          ["csharp|symbol_search"] = {
            dotnet_search_reference_assemblies = true,
          },
        },
      })
      vim.lsp.config("mdx_analyzer", {
        on_attach = function(client, _)
          client.server_capabilities.documentHighlightProvider = false
        end,
      })
      vim.lsp.config("eslint", {
        root_dir = function(bufnr, on_dir)
          if not uses_eslint(bufnr) then
            return
          end

          on_dir(get_project_root(bufnr))
        end,
      })
      vim.lsp.config("*", {
        on_attach = on_attach,
      })
      vim.lsp.config("rust_analyzer", {
        on_attach = function(client, bufnr)
          on_attach(client, bufnr)

          vim.api.nvim_buf_create_user_command(bufnr, "LspCargoReload", function()
            local clients = vim.lsp.get_clients({ bufnr = bufnr, name = "rust_analyzer" })
            for _, rust_client in ipairs(clients) do
              vim.notify("Reloading Cargo Workspace")
              rust_client:request("rust-analyzer/reloadWorkspace", nil, function(err)
                if err then
                  error(tostring(err))
                end
                vim.notify("Cargo workspace reloaded")
              end, bufnr)
            end
          end, { desc = "Reload current cargo workspace" })
        end,
      })
      require("mason-lspconfig").setup({
        automatic_enable = {
          exclude = { "ts_ls", "vtsls", "tsgo", "omnisharp" },
        },
      })
      local levels = vim.diagnostic.severity
      local opts = {
        virtual_text = true,
        float = {
          border = "rounded",
        },
        signs = {
          text = {
            [levels.ERROR] = "✘",
            [levels.WARN] = "▲",
            [levels.HINT] = "⚑",
            [levels.INFO] = "»",
          },
        },
      }
      vim.diagnostic.config(opts)
    end,
  },
  {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local conform = require("conform")

      local current_bufnr = -1
      local is_eslint_available = false
      local function biome_format(bufnr, fallback)
        if uses_biome(bufnr) then
          return { "biome-check" }
        end

        return fallback
      end

      local function javascript_format(bufnr)
        if uses_biome(bufnr) then
          return { "biome-check" }
        end

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
          astro = function(bufnr)
            return biome_format(bufnr, { "prettierd", "prettier", stop_after_first = true })
          end,
          svelte = function(bufnr)
            return biome_format(bufnr, { "prettierd", "prettier", stop_after_first = true })
          end,
          vue = function(bufnr)
            return biome_format(bufnr, { "prettierd", "prettier", stop_after_first = true })
          end,
          css = function(bufnr)
            return biome_format(bufnr, { "prettierd", "prettier", stop_after_first = true })
          end,
          html = function(bufnr)
            return biome_format(bufnr, { "prettierd", "prettier", stop_after_first = true })
          end,
          json = function(bufnr)
            return biome_format(bufnr, { "prettierd", "prettier", stop_after_first = true })
          end,
          jsonc = function(bufnr)
            return biome_format(bufnr, { "prettierd", "prettier", stop_after_first = true })
          end,
          yaml = { "prettierd", "prettier", stop_after_first = true },
          markdown = { "prettierd", "prettier", stop_after_first = true },
          graphql = function(bufnr)
            return biome_format(bufnr, { "prettierd", "prettier", stop_after_first = true })
          end,
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

      local function run_lint(bufnr)
        if vim.bo[bufnr].buftype ~= "" then
          return
        end

        vim.api.nvim_buf_call(bufnr, function()
          lint.try_lint(nil, { ignore_errors = true })
        end)
      end

      local lint_group = vim.api.nvim_create_augroup("app_nvim_lint", { clear = true })
      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
        group = lint_group,
        callback = function(event)
          run_lint(event.buf)
        end,
      })

      local keymap = vim.keymap
      keymap.set({ "n", "v" }, "<leader><C-s>", function()
        run_lint(vim.api.nvim_get_current_buf())
      end)
    end,
  },
}
