Console = {}

function Console:new(init)
  local c = {
    n = init or 0
  }
  setmetatable(c, self)
  self.__index = self
  return c
end

function Console:incr()
  self.n = self.n + 1
end
