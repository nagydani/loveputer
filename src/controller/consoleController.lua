ConsoleController = {}

function ConsoleController:new(m)
  local cc = {
    model = m
  }
  setmetatable(cc, self)
  self.__index = self
  return cc
end

function ConsoleController:increment()
  self.model:incr()
end

function ConsoleController:keypressed(k)
  if k == "return" then
    self.model.message = 'enter'
  end
end

function ConsoleController:textinput(t)
  local cur = self.model.entered
  self.model.entered = cur .. t
end
