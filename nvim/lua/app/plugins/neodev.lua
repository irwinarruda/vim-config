local s1, neodev = pcall(require, "neodev")

if not s1 then
  return
end

neodev.setup({
  library = { plugins = { "nvim-dap-ui", "nvim-treesitter", "plenary.nvim", "telescope.nvim" }, types = true },
})
