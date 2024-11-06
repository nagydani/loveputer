local class = require('util.class')
require("util.key")
require("util.string")

--- @param model InputModel
--- @param result function?
local new = function(model, result)
  return {
    model = model,
    result = result,
  }
end

--- @class UserInputController
--- @field model UserInputModel
--- @field result function
UserInputController = class.create(new)

---------------
--  entered  --
---------------

--- @param t str
function UserInputController:add_text(t)
  self.model:add_text(string.unlines(t))
end

--- @return InputText
function UserInputController:get_text()
  return self.model:get_text()
end

--- @param t str
function UserInputController:set_text(t)
  self.model:set_text(t)
end

function UserInputController:is_empty()
  local ent = self:get_text()
  local is_empty = not string.is_non_empty_string_array(ent)
  return is_empty
end

----------------
-- evaluation --
----------------

--- @param eval Evaluator
function UserInputController:set_eval(eval)
  self.model:set_eval(eval)
end

function UserInputController:clear()
  self.model:clear_input()
  self:clear_error()
end

--- @param cs CustomStatus
function UserInputController:set_custom_status(cs)
  self.model:set_custom_status(cs)
end

--- @return InputDTO
function UserInputController:get_input()
  return self.model:get_input()
end

--- @return Status
function UserInputController:get_status()
  return self.model:get_status()
end

--- @return CursorInfo
function UserInputController:get_cursor_info()
  return self.model:get_cursor_info()
end

--- @param cursor Cursor
function UserInputController:set_cursor(cursor)
  return self.model:set_cursor(cursor)
end

-----------
-- error --
-----------
--- @return boolean
function UserInputController:has_error()
  return self.model:has_error()
end

function UserInputController:clear_error()
  self.model:clear_error()
end

--- @param error string[]?
function UserInputController:set_error(error)
  self.model:set_error(error)
end

--- @return string[]?
function UserInputController:get_wrapped_error()
  return self.model:get_wrapped_error()
end

--- @return boolean
--- @return EvalError[]
function UserInputController:evaluate()
  return self.model:handle(true)
end

function UserInputController:cancel()
  self.model:handle(false)
end

function UserInputController:jump_home()
  self.model:jump_home()
end

----------------------
--- event handlers ---
----------------------

----------------
--  keyboard  --
----------------

--- @param k string
--- @return boolean? limit
function UserInputController:keypressed(k)
  if _G.web and k == 'space' then
    self:textinput(' ')
  end
  local input = self.model
  local ret

  if input:has_error() then
    if Key.is_enter(k)
        or k == "up" or k == "down"
    then
      input:clear_error()
    end
    return
  end

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

    if not Key.alt()
        and k == "home" then
      input:jump_home()
    end
    if not Key.alt()
        and k == "end" then
      input:jump_end()
    end
    if Key.alt()
        and k == "home" then
      input:jump_line_start()
    end
    if Key.alt()
        and k == "end" then
      input:jump_line_end()
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
    if not Key.shift() and Key.is_enter(k) and input.oneshot then
      local ok, evret = input:evaluate()
      if ok then
        local text = evret
        local res = self.result
        if type(res) == "function" then
          local t = string.unlines(text)
          res(t)
        end
      else
        local err = evret
        input:set_error(err)
      end
    end
  end

  if love.state.app_state == 'editor' then
    removers()
    horizontal()
    vertical() -- sets return
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

--- @param t string
function UserInputController:textinput(t)
  if self.model:has_error() then
    return
  end
  if not self.result and love.state.app_state == 'running' then
    return
  end
  self.model:add_text(t)
end

--- @param k string
function UserInputController:keyreleased(k)
  local input = self.model

  if input:has_error() then
    if k == 'space' then
      input:clear_error()
    end
    return
  end

  local function selection()
    if Key.is_shift(k) then
      input:release_selection()
    end
  end

  selection()
end

---------------
--   mouse   --
---------------

function UserInputController:_translate_to_input_grid(x, y)
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

function UserInputController:_handle_mouse(x, y, btn, handler)
  if btn == 1 then
    local im = self.model
    local n_lines = im:get_wrapped_text():get_text_length()
    local c, l = self:_translate_to_input_grid(x, y)
    if l < n_lines then
      handler(n_lines - l, c)
    end
  end
end

function UserInputController:mousepressed(x, y, btn)
  local im = self.model
  self:_handle_mouse(x, y, btn, function(l, c)
    im:mouse_click(l, c)
  end)
end

function UserInputController:mousereleased(x, y, btn)
  local im = self.model
  self:_handle_mouse(x, y, btn, function(l, c)
    im:mouse_release(l, c)
  end)
  im:release_selection()
end

function UserInputController:mousemoved(x, y, dx, dy)
  local im = self.model
  self:_handle_mouse(x, y, 1, function(l, c)
    im:mouse_drag(l, c)
  end)
end
