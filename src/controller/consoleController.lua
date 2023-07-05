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
  local function isEnter(k)
    return k == "return" or k == 'kpenter'
  end

  if isEnter(k) then
    self.model:evaluate()
  end
  if k == "backspace" then
    self.model:backspace()
  end
end

function ConsoleController:textinput(t)
  local ent = self.model.entered .. t
  self.model.entered = ent
end
