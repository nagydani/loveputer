require("util.range")

--- @param size_max integer
--- @param len integer
--- @return Range
local function calculate_end_range(size_max, len)
  local L = size_max
  local clen = len
  local off = math.max(clen - L, 0)
  local si = 1
  local ei = math.min(L, clen + 1)
  return Range(si, ei):translate(off)
end

return {
  calculate_end_range = calculate_end_range,
}
