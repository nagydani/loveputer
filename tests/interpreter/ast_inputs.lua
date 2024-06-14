require("util.string")

--- @param s string|string[]
--- @param canonized string|string[]?
-- @return {string[], string[]}
local prep = function(s, canonized)
  local orig = string.lines(s)
  local canon = string.lines(canonized) or orig

  return { orig, canon }
end

return {}
