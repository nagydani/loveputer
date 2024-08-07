require("util.range")

--- @param size_max integer
--- @param len integer
--- @return Range
local function calculate_end_range(size_max, len)
  local L = size_max
  local clen = len
  local off = math.max(clen - L, 0)
  if off > 0 then off = off + 1 end
  local si = 1 + off
  local ei = math.min(L, clen + 1) + off
  return Range(si, ei)
end

return {
  calculate_end_range = calculate_end_range,
}
