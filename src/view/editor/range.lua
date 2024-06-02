--- @class Range
--- @field start integer
--- @field fin integer
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
  local self = setmetatable({
    start = s, fin = e
  }, Range)
  return self
end
