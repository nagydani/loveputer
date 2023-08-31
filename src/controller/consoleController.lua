ConsoleController = {}

require("util.testTerminal")
require("util.eval")

function ConsoleController:new(m)
  local cc = {
    time = 0,
    model = m,
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

local function evaluate_input(input)
  local text = input:get_text()
  local syntax_ok, res = input:evaluate()
  if syntax_ok then
    local code = string.join(text, '\n')
    local f, load_err = loadstring(code)
    if f then
      local ok, call_err = pcall(f)
      if ok then
      else
        local e = parse_load_error(call_err)
        input:set_error(e, true)
      end
    else
      -- we should not see many of these, since the code is parsed prior
      orig_print(load_err)
    end
  else
    local eval_err = input:get_eval_error(res)
    if string.is_non_empty_string(eval_err) then
      orig_print(eval_err)
    end
  end
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
      TerminalTest:reset(out.terminal)
      love.state.testing = false
    end
  end

  input:clear_error()

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
      input:cursor_vertical_move('up')
    end
    if k == "down" then
      input:cursor_vertical_move('down')
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
      evaluate_input(input, out)
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
      if k == 'o' then
        input:test_lua_eval()
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
  self.model.input:text_change()
end

function ConsoleController:mousepressed(x, y, btn)
  orig_print(string.format('down {%d, %d}', x, y), btn)
end

function ConsoleController:mousereleased(x, y, btn)
  orig_print(string.format('up {%d, %d}', x, y), btn)
end

function ConsoleController:get_terminal()
  return self.model.output.terminal
end

function ConsoleController:get_input()
  local im = self.model.input
  return {
    text = im:get_text(),
    error = im:get_error(),
    highlight = im:highlight(),
  }
end

function ConsoleController:get_cursor_info()
  return self.model.input:get_cursor_info()
end

function ConsoleController:get_status()
  return self.model.input:get_status()
end

function ConsoleController:autotest()
  local input = self.model.input
  local output = self.model.output
  local term = output.terminal
  local w = term.width
  local h = term.height
  local char = 'x'
  for _ = 1, (w * h) do
    input:add_text(char)
  end
  evaluate_input(input, output)
  input:add_text(char)
end
