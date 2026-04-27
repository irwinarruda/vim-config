local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"
local path = vim.env.PATH or ""
if not vim.tbl_contains(vim.split(path, ":", { plain = true }), mason_bin) then
  vim.env.PATH = mason_bin .. (path == "" and "" or ":" .. path)
end

require("app.core.options")
require("app.core.keymaps")
require("app.lazy")
