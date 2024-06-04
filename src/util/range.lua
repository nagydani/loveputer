--- @class Range
--- @field start integer
--- @field fin integer
---
--- @field inc fun(self, integer): boolean
--- @field translate fun(self, integer): Range
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

--- Translate functions do not modify the original

--- @param by integer
--- @return Range
function Range:translate(by)
  if type(by) == 'number' then
    return Range(self.start + by, self.fin + by)
  else
    error()
  end
end

--- @param by integer
--- @param ll integer
--- @param ul integer
--- @return Range
function Range:translate_limit(by, ll, ul)
  if type(by) == 'number' then
    local s, e = self.start, self.fin
    if by < 0 then
      local down = (function()
        if ll then
          return math.max(by, ll - s, ll - e)
        end
        return by
      end)()
      return self:translate(down)
    elseif by > 0 then
      local up = (function()
        if ul then
          return math.min(by, ul - s, ul - e)
        end
        return by
      end)()
      return self:translate(up)
    end
  else
    error()
  end
  return Range(self.start, self.fin)
end
