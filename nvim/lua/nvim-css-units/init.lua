--- @return boolean
local function is_insert_mode()
  local mode = vim.api.nvim_get_mode().mode
  return mode == "i" or mode == "ic" or mode == "ix" or mode == "R"
end

--- @param num number
--- @param max_decimal_places number?
--- @return number
local function get_decimal_places(num, max_decimal_places)
  local _, decimal = math.modf(num)
  if decimal == 0 then
    return 0
  end
  local decimal_str = tostring(decimal)
  local decimal_count = string.len(decimal_str) - 2
  if max_decimal_places then
    return math.min(decimal_count, max_decimal_places)
  end
  return decimal_count
end

--- @param num number
--- @param max_decimal_places number?
--- @param unit string?
--- @return string
local function format_number(num, max_decimal_places, unit)
  if not unit then
    unit = ""
  end
  local decimal_places = get_decimal_places(num, max_decimal_places)
  return string.format("%." .. decimal_places .. "f" .. unit, num)
end

--- @param num number
--- @param base number?
--- @return string
local function to_rem(num, base)
  if not base then
    base = 16
  end
  return format_number(num / base, 3, "rem")
end

--- @param num number
--- @param base number?
--- @return string
local function to_px(num, base)
  if not base then
    base = 16
  end
  return format_number(num * base, 3, "px")
end

--- @param str string
--- @param pattern string
--- @return fun():string?, number?, number?
local function gmatch_with_positions(str, pattern)
  local iterator = string.gmatch(str, pattern)
  local init = 1
  return function()
    local match = { iterator() }
    if #match > 0 then
      local start, end_pos = string.find(str, match[1], init)
      init = end_pos + 1
      return unpack(match), start, end_pos
    end
    return nil, nil, nil
  end
end

--- @class CSSValue
--- @field num number
--- @field unit string
--- @field start_pos number
--- @field end_pos number
local CSSValue = {}

--- @param num number
--- @param unit string
--- @param start_pos number
--- @param end_pos number
--- @return CSSValue
function CSSValue:new(num, unit, start_pos, end_pos)
  local o = {}
  setmetatable(o, self)
  o.num = num
  o.unit = unit
  o.start_pos = start_pos
  o.end_pos = end_pos
  return o
end

--- @class CSSUtilsConfig
--- @field base_px number
--- @field units string[]?
--- @field units_fn table<string, function>?
--- @field units_to table<string, string>?
local config = {
  base_px = 16,
  units = { "px", "rem" },
  units_fn = { px = to_px, rem = to_rem },
  units_to = { px = "rem", rem = "px" },
}

local M = {}

--- @param num number
--- @param unit string
--- @return string
function M.convert_num(num, unit)
  return config.units_fn[config.units_to[unit]](num, config.base_px)
end

--- @param opts CSSUtilsConfig
M.setup = function(opts)
  config = vim.tbl_extend("force", config, opts)
end

M.toggle_unit = function()
  local bufnr = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local cursor_line = cursor[1]
  local cursor_col = cursor[2]

  if not is_insert_mode() then
    cursor_col = cursor_col + 1
  end
  local line_text = vim.api.nvim_buf_get_lines(bufnr, cursor_line - 1, cursor_line, false)[1]

  --- @type CSSValue[]
  local line_values = {}
  for _, unit in pairs(config.units) do
    for num_unit, start_pos, end_pos in gmatch_with_positions(line_text, "%d*%.?%d*" .. unit) do
      local num_text = string.sub(num_unit, 1, string.len(num_unit) - string.len(unit))
      local num = tonumber(num_text)
      if num then
        table.insert(line_values, CSSValue:new(num, unit, start_pos, end_pos))
      end
    end
  end
  for _, value in pairs(line_values) do
    if value.start_pos <= cursor_col and value.end_pos >= cursor_col then
      local refactored_num = M.convert_num(value.num, value.unit)
      vim.fn.cursor({ cursor_line, value.start_pos })
      xpcall(function()
        vim.cmd("normal! cf" .. string.sub(value.unit, -1) .. refactored_num)
        if is_insert_mode() then
          vim.cmd("normal! l")
        end
      end, function(err)
        print(err)
      end)
      if not is_insert_mode() then
        local end_pos = math.min(value.start_pos + string.len(refactored_num) - 1, cursor_col)
        vim.fn.cursor({ cursor_line, end_pos })
      else
        vim.fn.cursor({ cursor_line, value.start_pos + string.len(refactored_num) })
      end
    end
  end
end

M.copy_to_rem = function()
  vim.ui.input({ prompt = "Number (px): " }, function(num)
    num = tonumber(num)
    if not num then
      return
    end
    local rem = to_rem(num)
    vim.fn.setreg("+", rem)
    print(rem)
  end)
end

M.copy_to_px = function()
  vim.ui.input({ prompt = "Number (rem): " }, function(num)
    num = tonumber(num)
    if not num then
      return
    end
    local px = to_px(num)
    vim.fn.setreg("+", px)
    print(px)
  end)
end

return M
