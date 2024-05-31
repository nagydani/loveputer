require("util.key")

--- @class InputController
--- @field model InputModel
--- @field result function
InputController = {}
InputController.__index = InputController

setmetatable(InputController, {
  __call = function(cls, ...)
    return cls.new(...)
  end,
})

--- @param M InputModel
--- @param result function?
function InputController.new(M, result)
  local self = setmetatable({
    model = M,
    result = result,
  }, InputController)

  return self
end

--- @param t string
function InputController:textinput(t)
  if not self.result and love.state.app_state == 'running' then
    return
  end
  self.model:add_text(t)
end

--- @param t string|string[]
function InputController:add_text(t)
  self.model:add_text(string.unlines(t))
end

----------------
-- evaluation --
----------------
--- @param eval EvalBase
function InputController:set_eval(eval)
  self.model:set_eval(eval)
end

--- @param t string|string[]
function InputController:set_text(t)
  self.model:set_text(t)
end

function InputController:clear()
  self.model:clear_input()
end

--- @param k string
--- @return boolean? limit
function InputController:keypressed(k)
  local input = self.model
  local ret

  -- utility functions
  local function paste()
    input:paste(love.system.getClipboardText())
    input:clear_selection()
  end
  local function copy()
    local t = input:get_selected_text()
    love.system.setClipboardText(string.unlines(t))
  end
  local function cut()
    local t = input:pop_selected_text()
    love.system.setClipboardText(string.unlines(t))
  end

  -- action categories
  local function removers()
    if k == "backspace" then
      input:backspace()
    end
    if k == "delete" then
      input:delete()
    end
  end
  local function vertical()
    if k == "up" then
      local l = input:cursor_vertical_move('up')
      ret = l
    end
    if k == "down" then
      local l = input:cursor_vertical_move('down')
      ret = l
    end
  end
  local function horizontal()
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
  end
  local function newline()
    if Key.shift() then
      if Key.is_enter(k) then
        input:line_feed()
      end
    end
  end
  local function copypaste()
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
    if Key.shift() then
      if k == "insert" then
        paste()
      end
      if k == "delete" then
        cut()
      end
    end
  end
  local function selection()
    if Key.shift() then
      input:hold_selection()
    end
  end

  local function cancel()
    if not Key.ctrl() and k == "escape" then
      input:cancel()
    end
  end
  local function submit()
    if not Key.shift() and Key.is_enter(k) then
      input:finish()
      local res = self.result
      if type(res) == "function" then
        res(string.unlines(input:get_text()))
      end
    end
  end

  if love.state.app_state == 'editor' then
    removers()
    horizontal()
    newline()

    copypaste()
    selection()

    submit()
  else
    -- normal behavior
    removers()
    vertical()
    horizontal()
    newline()

    copypaste()
    selection()

    cancel()
    submit()
  end


  return ret
end

--- @param k string
function InputController:keyreleased(k)
  local input = self.model
  local function selection()
    if Key.shift() then
      input:release_selection()
    end
  end

  selection()
end

--- @return InputDTO
function InputController:get_input()
  local im = self.model
  return {
    text = im:get_text(),
    wrapped_text = im:get_wrapped_text(),
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

---------------
--   mouse   --
---------------
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
    local n_lines = im:get_wrapped_text():get_n_lines()
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
