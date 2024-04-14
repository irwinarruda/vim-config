local utils = require("nvim-css-units.utils")
local Globals = require("nvim-css-units.globals")

local globals = Globals:new()

local M = {}

--- @param opts CSSUnitsConfig
function M.setup(opts)
  globals:set_config(opts)
end

function M.toggle_unit()
  local ctx = globals:get_context()

  if not utils.is_insert_mode() then
    ctx.cursor_col = ctx.cursor_col + 1
  end

  local row_values = globals:get_values(ctx)
  for _, value in pairs(row_values) do
    if value.start_pos <= ctx.cursor_col and value.end_pos >= ctx.cursor_col then
      local refactored_num = globals:convert_num(value.num, value.unit)
      vim.fn.cursor({ ctx.cursor_row, value.start_pos })
      xpcall(function()
        vim.cmd("normal! cf" .. string.sub(value.unit, -1) .. refactored_num)
        if utils.is_insert_mode() then
          vim.cmd("normal! l")
        end
      end, function(err)
        print(err)
      end)
      if not utils.is_insert_mode() then
        local end_pos = math.min(value.start_pos + string.len(refactored_num) - 1, ctx.cursor_col)
        vim.fn.cursor({ ctx.cursor_row, end_pos })
      else
        vim.fn.cursor({ ctx.cursor_row, value.start_pos + string.len(refactored_num) })
      end
    end
  end
end

function M.toggle_virt_text()
  globals:set_virt_text(not globals.config.virt_text.enabled)
end

function M.copy_to_rem()
  vim.ui.input({ prompt = "Number (px): " }, function(num)
    num = tonumber(num)
    if not num then
      return
    end
    local rem = utils.to_rem(num)
    vim.fn.setreg("+", rem)
    print(rem)
  end)
end

function M.copy_to_px()
  vim.ui.input({ prompt = "Number (rem): " }, function(num)
    num = tonumber(num)
    if not num then
      return
    end
    local px = utils.to_px(num)
    vim.fn.setreg("+", px)
    print(px)
  end)
end

return M
