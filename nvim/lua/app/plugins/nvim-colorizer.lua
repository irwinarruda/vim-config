local s1, colorizer = pcall(require, "colorizer")

if not s1 then
  return
end

colorizer.setup()

vim.api.nvim_create_autocmd("BufWritePre", {
  group = vim.api.nvim_create_augroup("Colorizer", { clear = false }),
  desc = "Update colorizer on save",
  pattern = "*",
  callback = function(args)
    colorizer.attach_to_buffer(args.buf)
  end,
})
