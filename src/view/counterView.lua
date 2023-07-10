CounterView = {}

function CounterView:new(m)
  local v = {
    model = m
  }
  setmetatable(v, self)
  self.__index = self
  return v
end

function CounterView:draw()
  love.graphics.print(self.model.n)
end
