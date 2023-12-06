InputController = {}

--- @param M Model
function InputController:new(M)
  local ic = {
    model = M
  }

  setmetatable(ic, self)
  self.__index = self

  return ic
end

function InputController:textinput(t)
  -- TODO: block with events
  self.model.interpreter:add_text(t)
end

function InputController:get_input()
  local im = self.model
  local wt, wt_info = im:get_wrapped_text()
  return {
    text = im:get_text(),
    wrapped_text = wt,
    wt_info = wt_info,
    -- wrapped_error = im:get_wrapped_error(),
    highlight = im:highlight(),
    selection = im:get_ordered_selection(),
  }
end

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

function InputController:mousemoved(x, y)
  local im = self.model
  self:_handle_mouse(x, y, 1, function(l, c)
    im:mouse_drag(l, c)
  end)
end
