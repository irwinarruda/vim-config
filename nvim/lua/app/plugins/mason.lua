return {
  "WhoIsSethDaniel/mason-tool-installer.nvim",
  dependencies = {
    "williamboman/mason-lspconfig.nvim",
  },
  priority = 1000,
  config = function()
    require("mason").setup({})
    require("mason-tool-installer").setup({
      ensure_installed = {
        "dockerls",
        "docker_compose_language_service",
        "yamlls",
        "bashls",
        "eslint",
        "eslint_d",
        "prettier",
        "prettierd",
        "clangd",
        "html",
        "emmet_ls",
        "cssls",
        "cssmodules_ls",
        "tailwindcss",
        "tsserver",
        "svelte",
        "volar",
        "jsonls",
        "lua_ls",
        "stylua",
        "rust_analyzer",
        "gopls",
        "templ",
        "pylsp",
        "kotlin_language_server",
      },
    })
    vim.cmd("MasonUpdate")
  end,
}
