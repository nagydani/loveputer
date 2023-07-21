ConsoleController = {}

require("tests/test_terminal")

function ConsoleController:new(m, init)
  local cc = {
    time = init or 0,
    model = m
  }
  setmetatable(cc, self)
  self.__index = self

  return cc
end

function ConsoleController:pass_time(dt)
  self.time = self.time + dt
end

function ConsoleController:get_timestamp()
  return self.time
end

function ConsoleController:keypressed(k)
  local function is_enter()
    return k == "return" or k == 'kpenter'
  end

  local ctrl, shift
  ctrl  = love.keyboard.isDown("lctrl", "rctrl")
  shift = love.keyboard.isDown("lshift", "rshift")

  if not shift and is_enter() then
    local res = self.model.input:evaluate()
    self.model.output:push(res)
  end
  if not ctrl and k == "escape" then
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
    if love.DEBUG then
      local o = self.model.output
      if k == 't' then
        TerminalTest:test(o)
      end
    end
  end

  -- Shift held
  if shift then
    if k == "insert" then
      self.model.input:paste(love.system.getClipboardText())
    end
    if is_enter() then
      self.model.input:line_feed()
    end
  end
end

function ConsoleController:textinput(t)
  self.model.input:add_text(t)
end

function ConsoleController:get_result()
  return self.model.output.result
end

function ConsoleController:get_canvas()
  return self.model.output.canvas
end

function ConsoleController:get_input()
  return self.model.input:get_text()
end

function ConsoleController:get_status()
  return self.model.input:get_status()
end
