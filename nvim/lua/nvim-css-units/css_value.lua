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

return CSSValue
