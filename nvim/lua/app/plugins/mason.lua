return {
  "WhoIsSethDaniel/mason-tool-installer.nvim",
  dependencies = {
    "williamboman/mason-lspconfig.nvim",
    "Hoffs/omnisharp-extended-lsp.nvim",
    "yioneko/nvim-vtsls",
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
        "html",
        "emmet_ls",
        "omnisharp",
        "cssls",
        "cssmodules_ls",
        "tailwindcss",
        "ts_ls",
        "vtsls",
        "svelte",
        "volar",
        "jsonls",
        "lua_ls",
        "stylua",
        "rust_analyzer",
        "gopls",
        "goimports",
        "templ",
        "pylsp",
        "kotlin_language_server",
      },
    })
    vim.cmd("MasonToolsUpdate")
  end,
}
