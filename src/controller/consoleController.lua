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

  local ctrl, shift
  ctrl  = love.keyboard.isDown("lctrl", "rctrl")
  shift = love.keyboard.isDown("lshift", "rshift")

  if isEnter(k) then
    self.model:evaluate()
  end
  if k == "backspace" then
    self.model:backspace()
  end

  -- Ctrl held
  if ctrl then
    if k == "v" then
      self.model:paste(love.system.getClipboardText())
    end
  end

  -- Shift held
  if shift then
    if k == "insert" then
      self.model:paste(love.system.getClipboardText())
    end
  end
end

function ConsoleController:textinput(t)
  local ent = self.model.entered .. t
  self.model.entered = ent
end
