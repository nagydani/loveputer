ConsoleController = {}

require("util.testTerminal")
require("util.eval")
require("util.table")

local G = love.graphics

function ConsoleController:new(m)
  local env = getfenv()
  local cc = {
    time = 0,
    model = m,
    base_env = table.clone(env),
    env = table.clone(env),
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

function ConsoleController:evaluate_input()
  local output = self.model.output
  local input = self.model.input

  local text = input:get_text()
  local syntax_ok, res = input:evaluate()
  if syntax_ok then
    local code = string.join(text, '\n')
    local f, load_err = load(code, '', 't', self.env)
    if f then
      G.push('all')
      output:draw_to()
      local ok, call_err = pcall(f)
      if ok then
      else
        local e = LANG.parse_load_error(call_err)
        input:set_error(e, true)
      end
      output:restore_main()
      G.pop()
    else
      -- we should not see many of these, since the code is parsed prior
      orig_print(load_err)
    end
  else
    local l, c, eval_err = input:get_eval_error(res)
    if string.is_non_empty_string(eval_err) then
      orig_print(eval_err)
      input:set_error(eval_err)
    end
  end
end

function ConsoleController:_reset_executor_env()
  self.env = table.clone(self.base_env)
end

function ConsoleController:reset()
  self.model.output:reset()
  self.model.input:reset()
  self:_reset_executor_env()
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

  if input:has_error() then
    input:clear_error()
    return
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
      self:evaluate_input()
    end
    if not ctrl and k == "escape" then
      input:cancel()
    end
  end

  local function paste() input:paste(love.system.getClipboardText()) end
  local function copy()
    local t = input:get_selected_text()
    love.system.setClipboardText(string.join(t, '\n'))
  end
  local function cut()
    local t = input:pop_selected_text()
    love.system.setClipboardText(string.join(t, '\n'))
  end
  -- Ctrl held
  if ctrl then
    if k == "v" then
      paste()
    end
    if k == "c" or k == "insert" then
      copy()
    end
    if k == "x" then
      cut()
    end
    if k == "l" then
      self:reset()
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
      paste()
    end
    if k == "delete" then
      cut()
    end
    if is_enter() then
      input:line_feed()
    end
    input:hold_selection()
  end
end

function ConsoleController:keyreleased(k)
  if k == "lshift" or k == "rshift" then
    local im = self.model.input
    im:release_selection()
  end
end

function ConsoleController:textinput(t)
  -- TODO: block with events
  self.model.input:add_text(t)
end

function ConsoleController:_translate_to_input_grid(x, y)
  local cfg = self.model.output.cfg
  local h = cfg.h
  local fh = cfg.fh
  local fw = cfg.fw
  local line = math.floor((h - y) / fh)
  local a, b = math.modf((x / fw))
  local char = a + 1
  if b > .5 then char = char + 1 end
  return char, line
end

function ConsoleController:_handle_mouse(x, y, btn, handler)
  if btn == 1 then
    local im = self.model.input
    local n_lines = #(im:get_wrapped_text())
    local c, l = self:_translate_to_input_grid(x, y)
    if l < n_lines then
      handler(n_lines - l, c)
    end
  end
end

function ConsoleController:mousepressed(x, y, btn)
  local im = self.model.input
  self:_handle_mouse(x, y, btn, function(l, c)
    im:mouse_click(l, c)
  end)
end

function ConsoleController:mousereleased(x, y, btn)
  local im = self.model.input
  self:_handle_mouse(x, y, btn, function(l, c)
    im:mouse_release(l, c)
  end)
  im:release_selection()
end

function ConsoleController:mousemoved(x, y)
  local im = self.model.input
  self:_handle_mouse(x, y, 1, function(l, c)
    im:mouse_drag(l, c)
  end)
end

function ConsoleController:get_terminal()
  return self.model.output.terminal
end

function ConsoleController:get_input()
  local im = self.model.input
  local wt, wt_info = im:get_wrapped_text()
  return {
    text = im:get_text(),
    wrapped_text = wt,
    wt_info = wt_info,
    wrapped_error = im:get_wrapped_error(),
    highlight = im:highlight(),
    selection = im:get_ordered_selection(),
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
  self:evaluate_input()
  input:add_text(char)
end
