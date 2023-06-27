CounterController = {}

function CounterController:new(counter)
  local cc = {
    model = counter
  }
  setmetatable(cc, self)
  self.__index = self
  return cc
end

function CounterController:increment()
  local n = self.model.n + 1
  local model = self.model
  model.n = n
  self.model = model
  -- return self
end
