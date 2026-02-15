local M = {}

--- Scan a directory for immediate subdirectories that are git repositories.
--- Follows symlinks so workspace layouts with linked repos are detected.
--- Returns a sorted list of { name = string, path = string }.
function M.find_git_repos(dir)
  local repos = {}
  local handle = vim.loop.fs_scandir(dir)
  if not handle then
    return repos
  end
  while true do
    local name, _ = vim.loop.fs_scandir_next(handle)
    if not name then
      break
    end
    local path = dir .. "/" .. name
    local real_path = vim.loop.fs_realpath(path)
    if real_path then
      local stat = vim.loop.fs_stat(real_path .. "/.git")
      if stat then
        table.insert(repos, { name = name, path = real_path })
      end
    end
  end
  table.sort(repos, function(a, b)
    return a.name < b.name
  end)
  return repos
end

--- Returns true when cwd looks like a workspace directory:
--- no .git at root but at least one subdirectory with .git.
function M.is_workspace(dir)
  dir = dir or vim.fn.getcwd()
  if vim.loop.fs_stat(dir .. "/.git") then
    return false
  end
  local repos = M.find_git_repos(dir)
  return #repos > 0
end

return M
