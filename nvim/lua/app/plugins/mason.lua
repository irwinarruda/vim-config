return {
  "WhoIsSethDaniel/mason-tool-installer.nvim",
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
  },
  priority = 1000,
  config = function()
    require("mason").setup({
      registries = {
        "github:mason-org/mason-registry",
        "github:Crashdummyy/mason-registry",
      },
    })
    require("mason-tool-installer").setup({
      ensure_installed = {
        "dockerls",
        "docker_compose_language_service",
        "yamlls",
        "bashls",
        "eslint",
        "eslint_d",
        "biome",
        "prettier",
        "prettierd",
        "html",
        "emmet_ls",
        "roslyn",
        "cssls",
        "cssmodules_ls",
        "tailwindcss",
        -- Latest tsgo currently does not advertise semantic tokens; keep the working build pinned.
        { "tsgo", version = "7.0.0-dev.20260423.1" },
        "ts_ls",
        "vtsls",
        "svelte",
        "vue-language-server",
        "jsonls",
        "mdx_analyzer",
        "lua_ls",
        "stylua",
        "rust_analyzer",
        "gopls",
        "goimports",
        "templ",
        "pylsp",
        "kotlin_language_server",
        "nginx_language_server",
      },
      auto_update = true,
    })
  end,
}
