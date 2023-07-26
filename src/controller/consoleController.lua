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
  self.model.output.terminal:update(dt)
end

function ConsoleController:get_timestamp()
  return self.time
end

function ConsoleController:keypressed(k)
  local out = self.model.output
  local input = self.model.input
  local function is_enter()
    return k == "return" or k == 'kpenter'
  end

  local function terminal_test()
    if not love.state.testing then
      love.state.testing = 'running'
      input:cancel()
      TerminalTest:test(out.terminal)
    elseif love.state.testing == 'waiting' then
      -- TerminalTest:reset(out.terminal)
      love.state.testing = false
    end
  end

  if love.state.testing == 'running' then
    return
  end
  if love.state.testing == 'waiting' then
    terminal_test()
    return
  end

  local ctrl, shift
  ctrl  = love.keyboard.isDown("lctrl", "rctrl")
  shift = love.keyboard.isDown("lshift", "rshift")

  -- input controls
  do
    if k == "backspace" then
      input:backspace()
    end
    if k == "delete" then
      input:delete()
    end

    if k == "up" then
      input:cursor_up()
    end
    if k == "down" then
      input:cursor_down()
    end
    if k == "left" then
      input:cursor_left()
    end
    if k == "right" then
      input:cursor_right()
    end

    if k == "pageup" then
      input:history_back()
    end
    if k == "pagedown" then
      input:history_fwd()
    end

    if k == "home" then
      input:jump_home()
    end
    if k == "end" then
      input:jump_end()
    end

    if not shift and is_enter() then
      local res = input:evaluate()
      out:push(res)
    end
    if not ctrl and k == "escape" then
      input:cancel()
    end
  end

  -- Ctrl held
  if ctrl then
    if k == "v" then
      input:paste(love.system.getClipboardText())
    end
    if k == "l" then
      out:clear()
    end
    if love.DEBUG then
      if k == 't' then
        terminal_test()
        return
      end
    end
  end

  -- Shift held
  if shift then
    if k == "insert" then
      input:paste(love.system.getClipboardText())
    end
    if is_enter() then
      input:line_feed()
    end
  end
end

function ConsoleController:textinput(t)
  -- TODO: block with events
  self.model.input:add_text(t)
end

function ConsoleController:get_terminal()
  return self.model.output.terminal
end

function ConsoleController:get_input()
  return self.model.input:get_text()
end

function ConsoleController:get_status()
  return self.model.input:get_status()
end
