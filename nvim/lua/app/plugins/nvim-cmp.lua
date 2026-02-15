return {
  "hrsh7th/nvim-cmp",
  event = "InsertEnter",
  dependencies = {
    "saadparwaiz1/cmp_luasnip",
    "hrsh7th/cmp-nvim-lsp",
    "L3MON4D3/LuaSnip",
    "nvim-os-persist",
  },
  config = function()
    local cmp = require("cmp")
    local luasnip = require("luasnip")

    require("luasnip.loaders.from_vscode").lazy_load()
    vim.opt.completeopt = "menu,menuone"

    local os = require("nvim-os-persist")

    local cmp_select = { behavior = cmp.SelectBehavior.Select }
    cmp.setup({
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      mapping = cmp.mapping.preset.insert({
        ["<C-p>"] = cmp.mapping(function()
          if cmp.visible() then
            cmp.select_prev_item(cmp_select)
          else
            local keys = vim.api.nvim_replace_termcodes("<C-r>+", true, false, true)
            vim.api.nvim_feedkeys(keys, "i", false)
          end
        end, { "i" }),
        ["<C-k>"] = cmp.mapping.select_prev_item(cmp_select), -- previous suggestion
        ["<C-j>"] = cmp.mapping.select_next_item(cmp_select), -- next suggestion
        [os.motion("cmp_complete")] = cmp.mapping.complete(), -- show completion suggestions
        ["<C-q>"] = cmp.mapping.abort(), -- close completion window
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
      }),
      -- sources for autocompletion
      sources = cmp.config.sources({
        { name = "nvim_lsp" }, -- lsp
        { name = "nvim_lua" }, -- lsp lua
        { name = "luasnip" }, -- snippets
        { name = "buffer" }, -- text within current buffer
        { name = "path" }, -- file system paths
      }),
    })
  end,
}
