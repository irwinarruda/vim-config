local s1, cmp = pcall(require, "cmp")
local s2, luasnip = pcall(require, "luasnip")

if not s1 or not s2 then
  return
end

require("luasnip.loaders.from_vscode").lazy_load()
vim.opt.completeopt = "menu,menuone"

local cmp_select = { behavior = cmp.SelectBehavior.Select }
cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-k>"] = cmp.mapping.select_prev_item(cmp_select), -- previous suggestion
    ["<C-j>"] = cmp.mapping.select_next_item(cmp_select), -- next suggestion
    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-Space>"] = cmp.mapping.complete(), -- show completion suggestions
    ["<C-e>"] = cmp.mapping.abort(), -- close completion window
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
  formatting = require("lsp-zero").cmp_format(),
})
