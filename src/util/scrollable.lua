require("util.range")
local class = require('util.class')

--- @class Scrollable
Scrollable = class.create()

--- @param size_max integer
--- @param len integer
--- @return Range
function Scrollable.calculate_end_range(size_max, len)
  local L = size_max
  local clen = len or 0
  local off = math.max(clen - L, 0)
  local si = 1
  local ei = math.min(L, clen + 1)
  return Range(si, ei):translate(off)
end

function Scrollable.to_end(size_max, len)
  local end_r = Scrollable.calculate_end_range(size_max, len)
  return end_r
end
