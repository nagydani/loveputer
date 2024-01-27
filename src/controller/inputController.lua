require("util.key")

--- @class InputController
--- @field model InputModel
--- @field result function
InputController = {}

--- @param M InputModel
--- @param result function?
function InputController:new(M, result)
  local ic = {
    model = M,
    result = result,
  }

  setmetatable(ic, self)
  self.__index = self

  return ic
end

--- @param t string
function InputController:textinput(t)
  if love.state.app_state == 'running' then
    return
  end
  self.model:add_text(t)
end

--- @param k string
--- @return boolean? limit
function InputController:keypressed(k)
  local input = self.model

  if k == "backspace" then
    input:backspace()
  end
  if k == "delete" then
    input:delete()
  end

  if k == "up" then
    local l = input:cursor_vertical_move('up')
    return l
  end
  if k == "down" then
    local l = input:cursor_vertical_move('down')
    return l
  end
  if k == "left" then
    input:cursor_left()
  end
  if k == "right" then
    input:cursor_right()
  end

  if k == "home" then
    input:jump_home()
  end
  if k == "end" then
    input:jump_end()
  end

  if not Key.ctrl() and k == "escape" then
    input:cancel()
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
  if Key.ctrl() then
    if k == "v" then
      paste()
    end
    if k == "c" or k == "insert" then
      copy()
    end
    if k == "x" then
      cut()
    end
  end

  -- Shift held
  if Key.shift() then
    if k == "insert" then
      paste()
    end
    if k == "delete" then
      cut()
    end
    if Key.is_enter(k) then
      input:line_feed()
    end
    input:hold_selection()
  end

  if not Key.shift() and Key.is_enter(k) then
    input:finish()
    local res = self.result
    if res and type(res) == "function" then
      res(string.unlines(input:get_text()))
    end
  end
end

--- @param k string
function InputController:keyreleased(k)
  if Key.shift() then
    local im = self.model
    im:release_selection()
  end
end

--- @return InputDTO
function InputController:get_input()
  local im = self.model
  local wt, wt_info = im:get_wrapped_text()
  return {
    text = im:get_text(),
    wrapped_text = wt,
    wt_info = wt_info,
    highlight = im:highlight(),
    selection = im:get_ordered_selection(),
  }
end

--- @return Status
function InputController:get_status()
  return self.model:get_status()
end

--- @return CursorInfo
function InputController:get_cursor_info()
  return self.model:get_cursor_info()
end

function InputController:_translate_to_input_grid(x, y)
  local cfg = self.model.cfg
  local h = cfg.view.h
  local fh = cfg.view.fh
  local fw = cfg.view.fw
  local line = math.floor((h - y) / fh)
  local a, b = math.modf((x / fw))
  local char = a + 1
  if b > .5 then char = char + 1 end
  return char, line
end

function InputController:_handle_mouse(x, y, btn, handler)
  if btn == 1 then
    local im = self.model
    local n_lines = #(im:get_wrapped_text())
    local c, l = self:_translate_to_input_grid(x, y)
    if l < n_lines then
      handler(n_lines - l, c)
    end
  end
end

function InputController:mousepressed(x, y, btn)
  local im = self.model
  self:_handle_mouse(x, y, btn, function(l, c)
    im:mouse_click(l, c)
  end)
end

function InputController:mousereleased(x, y, btn)
  local im = self.model
  self:_handle_mouse(x, y, btn, function(l, c)
    im:mouse_release(l, c)
  end)
  im:release_selection()
end

function InputController:mousemoved(x, y, dx, dy)
  local im = self.model
  self:_handle_mouse(x, y, 1, function(l, c)
    im:mouse_drag(l, c)
  end)
end
