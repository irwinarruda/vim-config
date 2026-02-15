local utils = require("nvim-css-units.utils")
local CSSValue = require("nvim-css-units.css_value")

--- @class Context
--- @field bufnr number?
--- @field cursor_row number
--- @field cursor_col number
--- @field row_text string
--- @field row_values (CSSValue[])?

--- @class CSSUnitsConfigVirtText
--- @field enabled boolean
--- @field debounce number

--- @class CSSUnitsConfig
--- @field base_px number
--- @field units string[]?
--- @field units_fn table<string, function>?
--- @field units_to table<string, string>?
--- @field virt_text CSSUnitsConfigVirtText?

--- @class CSSUnitsGlobals
--- @field autocmd_id number?
--- @field timer number?
--- @field curr_ctx Context?
--- @field triggered_insert_leave boolean
--- @field config CSSUnitsConfig
local Globals = {
  autocmd_id = nil,
  timer = nil,
  curr_ctx = nil,
  triggered_insert_leave = false,
  config = {
    base_px = 16,
    units = { "px", "rem" },
    units_fn = { px = utils.to_px, rem = utils.to_rem },
    units_to = { px = "rem", rem = "px" },
    virt_text = {
      enabled = true,
      debounce = 500,
    },
  },
}

--- @return CSSUnitsGlobals
function Globals:new()
  local o = {}
  setmetatable(o, self)
  self.__index = self
  return o
end

--- @param new_config CSSUnitsConfig
function Globals:set_config(new_config)
  self.config = vim.tbl_extend("force", self.config, new_config)
  if new_config.virt_text then
    self.config.virt_text = vim.tbl_extend("force", self.config.virt_text, new_config.virt_text)
    self:set_virt_text(self.config.virt_text.enabled)
  end
end

--- @return Context
function Globals:get_context()
  local bufnr = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local cursor_row = cursor[1]
  local cursor_col = cursor[2]
  local row_text = vim.api.nvim_buf_get_lines(bufnr, cursor_row - 1, cursor_row, false)[1]
  local new_context = {
    bufnr = bufnr,
    cursor_row = cursor_row,
    cursor_col = cursor_col,
    row_text = row_text,
  }
  if self.curr_ctx and self.curr_ctx.bufnr == bufnr and self.curr_ctx.cursor_row == cursor_row then
    new_context.row_text = self.curr_ctx.row_text
    new_context.row_values = self.curr_ctx.row_values
  else
    self.curr_ctx = nil
  end

  return new_context
end

--- @param num number
--- @param unit string
--- @return string
function Globals:convert_num(num, unit)
  return self.config.units_fn[self.config.units_to[unit]](num, self.config.base_px)
end

--- @param ctx Context
--- @return CSSValue[]
function Globals:get_values(ctx)
  local line = ctx.row_text
  if ctx.row_values then
    return ctx.row_values
  end
  --- @type CSSValue[]
  local line_values = {}
  for _, unit in pairs(self.config.units) do
    for num_unit, start_pos, end_pos in utils.gmatch_with_positions(line, "%d*%.?%d*" .. unit) do
      local num_text = string.sub(num_unit, 1, string.len(num_unit) - string.len(unit))
      local num = tonumber(num_text)
      if num then
        table.insert(line_values, CSSValue:new(num, unit, start_pos, end_pos))
      end
    end
  end
  table.sort(line_values, function(a, b)
    return a.start_pos < b.start_pos
  end)
  return line_values
end

--- @param ctx Context
function Globals:create_virt_text(ctx)
  local namespace = vim.api.nvim_create_namespace("nvim-css-units")
  local line_values = self:get_values(ctx)
  if #line_values ~= 0 then
    local formatted = ""
    for _, value in pairs(line_values) do
      formatted = formatted .. " " .. self:convert_num(value.num, value.unit)
    end
    vim.api.nvim_buf_set_extmark(ctx.bufnr, namespace, ctx.cursor_row - 1, 0, {
      virt_text = { { formatted, "Comment" } },
      id = namespace,
      priority = 100,
    })
    ctx.row_values = line_values
    self.curr_ctx = ctx
  end
end

function Globals:show_virtual_text()
  if self.timer then
    vim.fn.timer_stop(self.timer)
  end
  if not self.config.virt_text.enabled then
    return
  end
  local ctx = self:get_context()
  if ctx.row_values then
    return
  end
  local namespace = vim.api.nvim_create_namespace("nvim-css-units")
  vim.api.nvim_buf_del_extmark(ctx.bufnr, namespace, namespace)
  self.timer = vim.fn.timer_start(self.config.virt_text.debounce, function()
    self:create_virt_text(ctx)
    self.timer = nil
  end)
end

--- @param enable boolean
function Globals:set_virt_text(enable)
  local ctx = self:get_context()
  if enable then
    self.autocmd_id = vim.api.nvim_create_autocmd({ "CursorMoved", "TextChanged", "InsertLeave" }, {
      group = vim.api.nvim_create_augroup("NvimCssPersist", { clear = false }),
      desc = "Persist CSS units",
      pattern = "*",
      callback = function(ev)
        if ev.event == "InsertLeave" or ev.event == "TextChanged" then
          self.curr_ctx = nil
          self:create_virt_text(self:get_context())
          self.triggered_insert_leave = true
          return
        end
        if self.triggered_insert_leave then
          self.triggered_insert_leave = false
          return
        end
        self:show_virtual_text()
      end,
    })
    if vim.api.nvim_buf_is_loaded(ctx.bufnr) and vim.api.nvim_buf_get_option(ctx.bufnr, "buftype") == "" then
      self:create_virt_text(ctx)
    end
  else
    if self.autocmd_id then
      local namespace = vim.api.nvim_create_namespace("nvim-css-units")
      vim.api.nvim_buf_del_extmark(ctx.bufnr, namespace, namespace)
      vim.api.nvim_del_autocmd(self.autocmd_id)
    end
  end
  self.config.virt_text.enabled = enable
end

return Globals
