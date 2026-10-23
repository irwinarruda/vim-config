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

--- Directory of the nearest of `files` above `filename`, searching no higher than `stop_dir`.
local function project_file_root(filename, files, stop_dir)
  local match = vim.fs.find(files, { path = filename, upward = true, type = "file", stop = stop_dir })[1]
  return match and vim.fs.dirname(match)
end

--- Directory of the nearest package.json above `filename`, if it mentions `field`.
local function package_json_root_with_field(filename, field, stop_dir)
  local package_json =
    vim.fs.find(PACKAGE_JSON_FILES, { path = filename, upward = true, type = "file", stop = stop_dir })[1]
  local file = package_json and io.open(package_json, "r")
  if not file then
    return nil
  end
  local content = file:read("*a")
  file:close()
  return content:find(field, 1, true) and vim.fs.dirname(package_json) or nil
end

local function biome_root(filename, stop_dir)
  return project_file_root(filename, BIOME_CONFIG_FILES, stop_dir)
    or package_json_root_with_field(filename, "@biomejs/biome", stop_dir)
end

local function uses_biome(bufnr)
  if #vim.lsp.get_clients({ bufnr = bufnr, name = "biome" }) > 0 then
    return true
  end

  local filename = vim.api.nvim_buf_get_name(bufnr)
  if filename == "" then
    return false
  end

  return biome_root(filename, vim.fs.dirname(get_project_root(bufnr))) ~= nil
end

--- ESLint runs unless the project is Deno, or a Biome config sits closer to the file.
local function uses_eslint(bufnr)
  local filename = vim.api.nvim_buf_get_name(bufnr)
  if filename == "" or vim.fs.root(bufnr, { "deno.json", "deno.jsonc", "deno.lock" }) then
    return false
  end

  local stop_dir = vim.fs.dirname(get_project_root(bufnr))
  local eslint_root = project_file_root(filename, ESLINT_CONFIG_FILES, stop_dir)
    or package_json_root_with_field(filename, "eslintConfig", stop_dir)
  if not eslint_root then
    return false
  end

  local biome = biome_root(filename, stop_dir)
  return not biome or #eslint_root >= #biome
end

--- Roslyn anchors code lenses at the symbol name, and Neovim 0.12 indents each lens line
--- to that column. Re-anchor them at the line's indentation, where VS Code shows them.
local reanchored_clients = setmetatable({}, { __mode = "k" })
local function indent_code_lenses(client)
  if reanchored_clients[client] then
    return
  end
  reanchored_clients[client] = true

  -- Neovim's codelens requests with a callback instead of client.handlers, so wrap the request
  local request = client.request
  client.request = function(self, method, params, handler, bufnr)
    if handler and (method == "textDocument/codeLens" or method == "codeLens/resolve") then
      local on_result = handler
      handler = function(err, result, ctx, ...)
        local buf = ctx.bufnr or bufnr
        local lenses = method == "codeLens/resolve" and { result } or result
        for _, lens in ipairs(type(lenses) == "table" and lenses or {}) do
          if type(lens) == "table" and lens.range and vim.api.nvim_buf_is_loaded(buf) then
            local start = lens.range.start
            start.character = vim.api.nvim_buf_call(buf, function()
              return vim.fn.indent(start.line + 1)
            end)
          end
        end
        return on_result(err, result, ctx, ...)
      end
    end
    return request(self, method, params, handler, bufnr)
  end
end

return {
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "mason-org/mason-lspconfig.nvim",
      "nvim-os-persist",
      "saghen/blink.cmp",
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
      local levels = vim.diagnostic.severity
      vim.diagnostic.config({
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
      })

      local typescript_lsp = require("app.core.typescript-lsp").get()
      require("app.core.lsp-keymaps").setup(typescript_lsp)

      vim.lsp.config("*", {
        capabilities = require("blink.cmp").get_lsp_capabilities(),
      })

      if typescript_lsp == "tsc" then
        -- Code actions come from vtsls instead, which has the quick-fixes tsc lacks
        vim.lsp.config("tsc", {
          on_init = function(client)
            client.server_capabilities.codeActionProvider = nil
          end,
        })
        -- vtsls starts on demand (see app.core.lsp-keymaps) and only serves code actions,
        -- commands and file renames, so it never duplicates tsc's diagnostics or completions
        vim.lsp.config("vtsls", {
          handlers = {
            ["textDocument/publishDiagnostics"] = function() end,
          },
          on_init = function(client)
            local capabilities = client.server_capabilities
            client.server_capabilities = {
              textDocumentSync = capabilities.textDocumentSync,
              codeActionProvider = capabilities.codeActionProvider,
              executeCommandProvider = capabilities.executeCommandProvider,
              workspace = capabilities.workspace,
            }
          end,
        })
      end

      if typescript_lsp == "typescript-tools" then
        require("typescript-tools").setup({
          settings = {
            expose_as_code_action = "all",
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
      else
        vim.lsp.enable(typescript_lsp)
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
        -- on_init is left to roslyn.nvim, which uses it to open the solution
        on_attach = function(client, bufnr)
          if client:supports_method("textDocument/codeLens") then
            indent_code_lenses(client)
            vim.lsp.codelens.enable(true, { bufnr = bufnr })
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
        on_attach = function(client)
          client.server_capabilities.documentHighlightProvider = false
        end,
      })
      vim.lsp.config("eslint", {
        root_dir = function(bufnr, on_dir)
          if uses_eslint(bufnr) then
            on_dir(get_project_root(bufnr))
          end
        end,
      })
      vim.lsp.config("rust_analyzer", {
        on_attach = function(_, bufnr)
          vim.api.nvim_buf_create_user_command(bufnr, "LspCargoReload", function()
            for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr, name = "rust_analyzer" })) do
              vim.notify("Reloading Cargo Workspace")
              client:request("rust-analyzer/reloadWorkspace", nil, function(err)
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
          -- TypeScript servers are enabled above; stylua stays a conform formatter
          exclude = { "ts_ls", "vtsls", "tsc", "omnisharp", "stylua" },
        },
      })
    end,
  },
  {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local conform = require("conform")
      local prettier = { "prettierd", "prettier", stop_after_first = true }

      local function biome_or(fallback)
        return function(bufnr)
          return uses_biome(bufnr) and { "biome-check" } or fallback
        end
      end

      local function javascript_format(bufnr)
        if uses_biome(bufnr) then
          return { "biome-check" }
        end
        if #vim.lsp.get_clients({ bufnr = bufnr, name = "eslint" }) > 0 then
          return { "prettierd", "eslint_d" }
        end
        return { "prettierd" }
      end

      local formatters_by_ft = {
        lua = { "stylua" },
        yaml = prettier,
        markdown = prettier,
        go = { "gofmt", "goimports" },
        nginx = { "nginxfmt" },
      }
      for _, ft in ipairs({ "javascript", "typescript", "javascriptreact", "typescriptreact" }) do
        formatters_by_ft[ft] = javascript_format
      end
      for _, ft in ipairs({ "astro", "svelte", "vue", "css", "html", "json", "jsonc", "graphql" }) do
        formatters_by_ft[ft] = biome_or(prettier)
      end

      conform.setup({
        format_on_save = {
          timeout_ms = 1000,
          lsp_format = "fallback",
        },
        log_level = vim.log.levels.ERROR,
        formatters_by_ft = formatters_by_ft,
        formatters = {
          -- Need to install manually
          nginxfmt = {
            prepend_args = { "-i", "2" },
          },
        },
      })

      vim.keymap.set({ "n", "v" }, "<C-s>", function()
        conform.format({
          timeout_ms = 1000,
          async = false,
          lsp_format = "fallback",
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

      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
        group = vim.api.nvim_create_augroup("app_nvim_lint", { clear = true }),
        callback = function(event)
          run_lint(event.buf)
        end,
      })

      vim.keymap.set({ "n", "v" }, "<leader><C-s>", function()
        run_lint(vim.api.nvim_get_current_buf())
      end)
    end,
  },
}
