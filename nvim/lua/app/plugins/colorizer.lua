return {
  -- Maintained fork of norcalli/nvim-colorizer.lua (same API)
  "catgoose/nvim-colorizer.lua",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local colorizer = require("colorizer")
    colorizer.setup()

    vim.api.nvim_create_autocmd("BufWritePre", {
      group = vim.api.nvim_create_augroup("Colorizer", { clear = true }),
      desc = "Update colorizer on save",
      callback = function(args)
        colorizer.attach_to_buffer(args.buf)
      end,
    })
  end,
}
