--- @class Range
--- @field start integer
--- @field fin integer
---
--- @field inc fun(self, integer): boolean
Range = {}
Range.__index = Range

setmetatable(Range, {
  __call = function(cls, ...)
    return cls.new(...)
  end,
})

--- @param s integer
--- @param e integer
function Range.new(s, e)
  -- TODO: validate
  local self = setmetatable({
    start = s, fin = e
  }, Range)
  return self
end

--- @param n integer
function Range:inc(n)
  if self.start > n then return false end
  if self.fin < n then return false end
  return true
end
