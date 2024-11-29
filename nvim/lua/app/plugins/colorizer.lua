return {
  "norcalli/nvim-colorizer.lua",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local colorizer = require("colorizer")
    colorizer.setup()

    vim.api.nvim_create_autocmd("BufWritePre", {
      group = vim.api.nvim_create_augroup("Colorizer", { clear = false }),
      desc = "Update colorizer on save",
      pattern = "*",
      callback = function(args)
        colorizer.attach_to_buffer(args.buf)
      end,
    })
  end,
}
