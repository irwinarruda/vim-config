local status1, mason = pcall(require, "mason")
if not status1 then
  return
end

local status2, mason_lspconfig = pcall(require, "mason-lspconfig")
if not status2 then
  return
end

mason.setup()
mason_lspconfig.setup({
  ensure_installed = {
    'tsserver',
    'html',
    'cssls',
    'tailwindcss',
    'eslint',
    'dockerls',
    'jsonls',
    'sqlls',
    'svelte',
    'volar',
    'vuels',
    'lua_ls',
    'emmet_ls',
  }
}) 
