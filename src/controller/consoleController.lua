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
  local function is_enter(k)
    return k == "return" or k == 'kpenter'
  end

  local ctrl, shift
  ctrl  = love.keyboard.isDown("lctrl", "rctrl")
  shift = love.keyboard.isDown("lshift", "rshift")

  if is_enter(k) then
    local res = self.model.input:evaluate()
    self.model.canvas:push(res)
  end
  if k == "escape" then
    self.model.input:cancel()
  end

  if k == "backspace" then
    self.model.input:backspace()
  end
  if k == "delete" then
    self.model.input:delete()
  end

  if k == "up" then
    self.model.input:cursor_up()
  end
  if k == "down" then
    self.model.input:cursor_down()
  end
  if k == "left" then
    self.model.input:cursor_left()
  end
  if k == "right" then
    self.model.input:cursor_right()
  end

  if k == "pageup" then
    self.model.input:history_back()
  end
  if k == "pagedown" then
    self.model.input:history_fwd()
  end

  if k == "home" then
    self.model.input:jump_home()
  end
  if k == "end" then
    self.model.input:jump_end()
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
  self.model.input:add_text(t)
end

function ConsoleController:get_result()
  return self.model.canvas.result
end

function ConsoleController:get_input()
  return self.model.input:get_text()
end

function ConsoleController:get_status()
  return self.model.input:get_status()
end
