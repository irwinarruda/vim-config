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

return {
  is_insert_mode = is_insert_mode,
  get_decimal_places = get_decimal_places,
  format_number = format_number,
  to_rem = to_rem,
  to_px = to_px,
  gmatch_with_positions = gmatch_with_positions,
}
