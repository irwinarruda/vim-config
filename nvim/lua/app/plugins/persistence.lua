return {
  "folke/persistence.nvim",
  lazy = false,
  config = function()
    require("persistence").setup({})
    -- Wipe NvimTree buffers before any session save
    vim.api.nvim_create_autocmd("User", {
      pattern = "PersistenceSavePre",
      callback = function()
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          if vim.api.nvim_buf_get_name(buf):match("NvimTree_") then
            vim.api.nvim_buf_delete(buf, { force = true })
          end
        end
      end,
    })
    -- Auto-restore session when opened in a directory (no file arguments)
    if vim.fn.argc() == 0 then
      local ts_lsp = require("app.core.typescript-lsp")
      local pending_lsp_restore = ts_lsp.consume_pending_restore()
      vim.api.nvim_create_autocmd("VimEnter", {
        once = true,
        callback = function()
          vim.schedule(function()
            require("persistence").load()
            if pending_lsp_restore then
              vim.notify("Session restored. TypeScript LSP: " .. ts_lsp.get(), vim.log.levels.INFO)
            end
          end)
        end,
      })
    end
    vim.keymap.set("n", "<leader>qs", function()
      require("persistence").load()
    end)
  end,
}
