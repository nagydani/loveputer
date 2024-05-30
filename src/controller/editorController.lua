--- @class EditorController
--- @field model EditorModel
--- @field input InputController
--- @field view EditorView?
--- @field open fun(self, name: string, content: string[]?)
--- @field close fun(self): string[]
--- @field update_visible function
--- @field update_more function
EditorController = {}
EditorController.__index = EditorController

setmetatable(EditorController, {
  __call = function(cls, ...)
    return cls.new(...)
  end,
})

--- @param M EditorModel
function EditorController.new(M)
  local self = setmetatable({
    input = InputController.new(M.interpreter.input),
    model = M,
    view = nil,
  }, EditorController)

  return self
end

--- @param name string
--- @param content string[]?
function EditorController:open(name, content)
  local b = BufferModel(name, content)
  self.model.buffer = b
  self.view.buffer:open(b)
end

--- @return string[]
function EditorController:close()
  -- close buffer, return content
  return {}
end

--- @return BufferModel
function EditorController:get_active_buffer()
  return self.model.buffer
end

--- @param t string
function EditorController:textinput(t)
  local interpreter = self.model.interpreter
  if interpreter:has_error() then
    interpreter:clear_error()
  else
    if Key.ctrl() and Key.shift() then
      return
    end
    self.input:textinput(t)
  end
end

--- @param k string
function EditorController:keypressed(k)
  self.input:keypressed(k)

  -- enter submits, handled in the input
  if not Key.ctrl() and not Key.shift() and k == "escape" then
    local t = self:get_active_buffer():get_selected_text()
    self.input:set_text(t)
  end
  if Key.shift() and k == "escape" then
    local t = self:get_active_buffer():get_selected_text()
    self.input:add_text(t)
  end
  if Key.ctrl() and
      (k == "delete" or k == "y") then
    self:get_active_buffer():delete_selected_text()
    self.view:refresh()
  end
  if k == "up" then
    self:get_active_buffer():move_highlight('up')
  end
  if k == "down" then
    self:get_active_buffer():move_highlight('down')
  end
  if k == "pageup" then
    -- scroll up
  end
  if k == "pagedown" then
    -- scroll down
  end
end
