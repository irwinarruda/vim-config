local workspace = require("app.core.workspace")

local function workspace_git_status()
  local cwd = vim.fn.getcwd()

  -- If cwd is inside a git repo, fall back to builtin
  if workspace.is_inside_git_repo(cwd) then
    require("telescope.builtin").git_status()
    return
  end

  -- Find git repos in subdirectories
  local repos = workspace.find_git_repos(cwd)
  if #repos == 0 then
    vim.notify("No git repositories found in workspace", vim.log.levels.WARN)
    return
  end

  -- Collect modified files from all repos
  local results = {}
  for _, repo in ipairs(repos) do
    local output = vim.fn.systemlist("git -C " .. vim.fn.shellescape(repo.path) .. " status --porcelain")
    for _, line in ipairs(output) do
      if line ~= "" then
        local status = vim.trim(line:sub(1, 2))
        local file = line:sub(4)
        table.insert(results, {
          repo_name = repo.name,
          repo_path = repo.path,
          status = status,
          file = file,
          abs_path = repo.path .. "/" .. file,
        })
      end
    end
  end

  if #results == 0 then
    vim.notify("No changes found across workspace repositories", vim.log.levels.INFO)
    return
  end

  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local previewers = require("telescope.previewers")
  local action_state = require("telescope.actions.state")
  local actions = require("telescope.actions")
  local entry_display = require("telescope.pickers.entry_display")

  local displayer = entry_display.create({
    separator = " ",
    items = {
      { width = 4 },
      { remaining = true },
    },
  })

  local function make_display(entry)
    local value = entry.value
    local status_hl = "TelescopeResultsComment"
    if value.status:find("M") then
      status_hl = "diffChanged"
    elseif value.status:find("A") or value.status:find("%?") then
      status_hl = "diffAdded"
    elseif value.status:find("D") then
      status_hl = "diffRemoved"
    end
    return displayer({
      { value.status, status_hl },
      { "[" .. value.repo_name .. "] " .. value.file },
    })
  end

  pickers
    .new({}, {
      prompt_title = "Workspace Git Status",
      previewer = previewers.new_termopen_previewer({
        get_command = function(entry)
          local value = entry.value
          if value.status == "??" then
            return { "cat", value.abs_path }
          end
          return { "git", "-C", value.repo_path, "diff", "--color=always", "HEAD", "--", value.file }
        end,
      }),
      finder = finders.new_table({
        results = results,
        entry_maker = function(entry)
          return {
            value = entry,
            display = make_display,
            ordinal = entry.repo_name .. " " .. entry.status .. " " .. entry.file,
            path = entry.abs_path,
          }
        end,
      }),
      sorter = conf.generic_sorter({}),
      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          local entry = action_state.get_selected_entry()
          actions.close(prompt_bufnr)
          if entry and entry.value then
            vim.cmd("edit " .. vim.fn.fnameescape(entry.value.abs_path))
          end
        end)
        return true
      end,
    })
    :find()
end

return {
  "nvim-telescope/telescope.nvim",
  branch = "master",
  dependencies = { "nvim-telescope/telescope-dap.nvim", "nvim-lua/plenary.nvim" },
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")

    local ignore_file = vim.fn.stdpath("config") .. "/lua/app/plugins/.telescope_ignore"
    local dropdown_config = {
      theme = "dropdown",
      layout_config = {
        preview_cutoff = 1,
        width = function(_, max_columns, _)
          return math.min(max_columns, 90)
        end,
        height = function(_, _, max_lines)
          return math.min(max_lines, 15)
        end,
      },
    }

    telescope.setup({
      defaults = {
        mappings = {
          i = {
            ["<C-k>"] = actions.move_selection_previous, -- move to prev result
            ["<C-j>"] = actions.move_selection_next, -- move to next result
            ["<C-q>"] = actions.send_to_qflist + actions.open_qflist, -- move results to quickfix list
            ["<C-c>"] = actions.close, -- close telescope
          },
        },
      },
      pickers = {
        find_files = vim.tbl_extend("force", dropdown_config, {
          find_command = {
            "rg",
            "--files",
            "--hidden",
            "--no-ignore",
            "--ignore-file",
            ignore_file,
          },
        }),
        git_files = dropdown_config,
        buffers = dropdown_config,
        live_grep = vim.tbl_extend("force", dropdown_config, {
          additional_args = function()
            return {
              "--hidden",
              "--no-ignore",
              "--ignore-file",
              ignore_file,
            }
          end,
        }),
        lsp_references = dropdown_config,
        lsp_definitions = dropdown_config,
        diagnostics = dropdown_config,
      },
    })

    telescope.load_extension("dap")

    local builtin = require("telescope.builtin")
    local keymap = vim.keymap
    keymap.set("n", "<leader>fo", builtin.find_files) -- find files using custom ignore patterns
    keymap.set("n", "<leader>fp", builtin.git_files) -- find files in git
    keymap.set("n", "<leader>fg", workspace_git_status) -- find in changed files (workspace-aware)
    keymap.set("n", "<leader>ff", builtin.live_grep) -- find string in current working directory as you type
    keymap.set("n", "<leader>fb", builtin.buffers) -- find string in current working directory as you type
  end,
}
