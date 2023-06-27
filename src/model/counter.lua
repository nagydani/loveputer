Counter = {}

function Counter:new(init)
  local c = {
    n = init or 0
  }
  setmetatable(c, self)
  self.__index = self
  return c
end
