--- @class EditorController
--- @field model EditorModel
--- @field input InputController
--- @field view EditorView?
--- @field open fun(self, name: string, content: string[]?)
--- @field close fun(self): string, string[]
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
  local input = self.input
  local interpreter = self.model.interpreter
  local is_lua = string.match(name, '.lua$')
  if is_lua then
    input:set_eval(interpreter.luaInput)
  else
    input:set_eval(interpreter.textInput)
  end
  local b = BufferModel(name, content)
  self.model.buffer = b
  self.view.buffer:open(b)
  self:update_selection()
end

--- @return string name
--- @return string[] content
function EditorController:close()
  local buf = self:get_active_buffer()
  local content = buf.content
  self.input:clear()
  return buf.name, content
end

--- @return BufferModel
function EditorController:get_active_buffer()
  return self.model.buffer
end

--- @private
--- @param sel Selected
--- @return CustomStatus
function EditorController:_generate_status(sel)
  local cs = {
    line = sel[1],
    buflen = self:get_active_buffer():get_content_length() + 1
  }
  cs.__tostring = function(t)
    return 'L' .. t.line
  end

  return cs
end

-- @return BufferModel
function EditorController:update_selection()
  local sel = self:get_active_buffer():get_selection()
  local cs = self:_generate_status(sel)
  self.input:set_custom_status(cs)
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

  --- @param dir VerticalDir
  local function move_sel(dir)
    local m = self:get_active_buffer():move_selection(dir)
    if m then
      self.input:clear()
      self:update_selection()
    end
  end

  --- handlers
  local function submit()
    if not Key.ctrl() and not Key.shift() and Key.is_enter(k) then
      local newtext = self.input:get_input().text
      local insert = self:get_active_buffer():replace_selected_text(newtext)
      self.input:clear()
      self.view:refresh(insert)
      if insert then move_sel('down') end
      self:update_selection()
    end
  end
  local function load()
    if not Key.ctrl() and not Key.shift() and k == "escape" then
      local t = self:get_active_buffer():get_selected_text()
      self.input:set_text(t)
    end
    if Key.shift() and k == "escape" then
      local t = self:get_active_buffer():get_selected_text()
      self.input:add_text(t)
    end
  end
  local function delete()
    if Key.ctrl() and
        (k == "delete" or k == "y") then
      self:get_active_buffer():delete_selected_text()
      self.view:refresh()
    end
  end
  local function navigate()
    if k == "up" then
      move_sel('up')
    end
    if k == "down" then
      move_sel('down')
    end
    if k == "pageup" then
      -- scroll up
    end
    if k == "pagedown" then
      -- scroll down
    end
  end

  submit()
  load()
  delete()
  navigate()
end
