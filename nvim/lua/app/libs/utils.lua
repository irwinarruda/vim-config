--- @param num number
--- @param base number?
--- @return string
local to_rem = function(num, base)
  if not base then
    base = 16
  end
  local result = string.format("%.3frem", num / base)
  return result
end

--- @param num number
--- @param base number?
--- @return string
local to_px = function(num, base)
  if not base then
    base = 16
  end
  local result = string.format("%.3fpx", num * base)
  return result
end

--- @param hovered_text string
--- @param suffix string
--- @return boolean
local matches_number_with_suffix = function(hovered_text, suffix)
  return string.match(hovered_text, "%f[%a%d%.]%d*%.?%d*" .. suffix .. "%f[^%a%d%.]") ~= nil
end

--- @param text string
--- @param cursor_col number
--- @param suffix string
--- @return number?, number?, number?
local find_number_with_suffix = function(text, cursor_col, suffix)
  cursor_col = cursor_col + 1
  local start_pos, end_pos = string.find(text, "%d*%.?%d*" .. suffix)
  while start_pos > cursor_col or end_pos < cursor_col do
    start_pos, end_pos = string.find(text, "%d*%.?%d*" .. suffix, end_pos)
    if not start_pos or not end_pos then
      return nil, nil, nil
    end
  end
  if not start_pos or not end_pos then
    return nil, nil, nil
  end
  text = string.sub(text, start_pos, end_pos - string.len(suffix))
  local num = tonumber(text)
  if not num then
    return nil, nil, nil
  end
  return num, start_pos, end_pos
end

--- @param num number
--- @param line number
--- @param col number
--- @param suffix string
--- @return nil
local replace_number_with_suffix = function(num, line, col, suffix)
  local refactored_num
  if suffix == "px" then
    refactored_num = to_rem(num)
  else
    refactored_num = to_px(num)
  end
  vim.fn.cursor({ line, col })
  print(string.sub(suffix, string.len(suffix)))
  xpcall(function()
    vim.cmd("normal! cf" .. string.sub(suffix, string.len(suffix)) .. refactored_num)
  end, function(err)
    print(err)
  end)
end

local toggle_unit = function()
  local bufnr = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local cursor_line = cursor[1]
  local cursor_col = cursor[2]
  local line_text = vim.api.nvim_buf_get_lines(bufnr, cursor_line - 1, cursor_line, false)[1]
  local hovered_text = string.sub(line_text, cursor_col)
  local is_px = matches_number_with_suffix(hovered_text, "px")
  if is_px then
    local num, start_pos = find_number_with_suffix(line_text, cursor_col, "px")
    if not num or not start_pos then
      return
    end
    replace_number_with_suffix(num, cursor_line, start_pos, "px")
    return
  end
  local is_rem = matches_number_with_suffix(hovered_text, "rem")
  if is_rem then
    local num, start_pos = find_number_with_suffix(line_text, cursor_col, "rem")
    if not num or not start_pos then
      return
    end
    replace_number_with_suffix(num, cursor_line, start_pos, "rem")
    return
  end
end

vim.keymap.set("n", "<leader>af", toggle_unit)

vim.keymap.set("n", "<leader>ar", function()
  vim.ui.input({ prompt = "Number: " }, function(num)
    num = tonumber(num)
    if not num then
      return
    end
    local rem = to_rem(num)
    vim.fn.setreg("+", rem)
    print(rem)
  end)
end)
