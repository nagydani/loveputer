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
    local res = self.model.input:evaluate()
    self.model.canvas:push(res)
  end
  if k == "backspace" then
    self.model.input:backspace()
  end

  if k == "escape" then
    self.model.input:cancel()
  end

  -- Ctrl held
  if ctrl then
    if k == "v" then
      self.model.input:paste(love.system.getClipboardText())
    end
  end

  -- Shift held
  if shift then
    if k == "insert" then
      self.model.input:paste(love.system.getClipboardText())
    end
  end
end

function ConsoleController:textinput(t)
  self.model.input:addText(t)
end

function ConsoleController:getResult()
  return self.model.canvas.result
end

function ConsoleController:getInput()
  return self.model.input.entered
end

function ConsoleController:getStatus()
  return self.model.input:getStatus()
end
