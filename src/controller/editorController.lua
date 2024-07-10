require("controller.inputController")
require("controller.interpreterController")

--- @class EditorController
--- @field model EditorModel
--- @field interpreter InterpreterController
--- @field view EditorView?
---
--- @field open fun(self, name: string, content: string[]?)
--- @field close fun(self): string, string[]
--- @field get_active_buffer function
--- @field update_status function
--- @field textinput fun(self, string)
--- @field keypressed fun(self, string)
EditorController = {}
EditorController.__index = EditorController

setmetatable(EditorController, {
  __call = function(cls, ...)
    return cls.new(...)
  end,
})

--- @param M EditorModel
function EditorController.new(M)
  local IC = InputController.new(M.interpreter.input)
  local self = setmetatable({
    interpreter = InterpreterController.new(M.interpreter, IC),
    model = M,
    view = nil,
  }, EditorController)

  return self
end

--- @param name string
--- @param content string[]?
function EditorController:open(name, content)
  -- local is_lua = string.match(name, '.lua$')
  -- if is_lua then
  --   input:set_eval(interpreter.luaInput)
  -- else
  input:set_eval(interpreter.textInput)
  -- end
  local interM = self.model.interpreter
  local b = BufferModel(name, content)
  self.model.buffer = b
  self.view.buffer:open(b)
  self:update_status()
end

--- @return string name
--- @return string[] content
function EditorController:close()
  local buf = self:get_active_buffer()
  local content = buf.content
  self.interpreter:clear()
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
  local len = self:get_active_buffer():get_content_length() + 1
  local vrange = self.view.buffer.content:get_range()
  local vlen = self.view.buffer.content:get_content_length()
  local more = {
    up = vrange.start > 1,
    down = vrange.fin < vlen
  }
  local cs = {
    line = sel[1],
    buflen = len,
    more = more,
  }
  cs.__tostring = function(t)
    return 'L' .. t.line
  end

  return cs
end

function EditorController:update_status()
  local sel = self:get_active_buffer():get_selection()
  local cs = self:_generate_status(sel)
  self.interpreter:set_custom_status(cs)
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
    self.interpreter:textinput(t)
  end
end

function EditorController:get_input()
  return self.interpreter:get_input()
end

--- @param k string
function EditorController:keypressed(k)
  local vmove = self.interpreter:keypressed(k)

  --- @param dir VerticalDir
  --- @param by integer?
  --- @param warp boolean?
  local function move_sel(dir, by, warp)
    local m = self:get_active_buffer():move_selection(dir, by, warp)
    if m then
      self.interpreter:clear()
      self.view.buffer:follow_selection()
      self:update_status()
    end
  end

  --- @param dir VerticalDir
  --- @param warp boolean?
  local function scroll(dir, warp)
    self.view.buffer:_scroll(dir, nil, warp)
    self:update_status()
  end

  local function load_selection()
    local t = self:get_active_buffer():get_selected_text()
    self.interpreter:set_text(t)
  end


  --- handlers
  local function submit()
    if not Key.ctrl() and not Key.shift() and Key.is_enter(k) then
      local insert, n = self:get_active_buffer():replace_selected_text(newtext)
      self.input:clear()
      self.view:refresh()
      move_sel('down', n)
      load_selection()
      self:update_status()
      local newtext = self.interpreter:get_text()
    end
  end
  local function load()
    if not Key.ctrl() and
        not Key.shift()
        and k == "escape" then
      load_selection()
    end
    if not Key.ctrl() and
        Key.shift() and
        k == "escape" then
      local t = self:get_active_buffer():get_selected_text()
      self.interpreter:add_text(t)
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
    -- move selection
    if k == "up" and vmove then
      move_sel('up')
    end
    if k == "down" and vmove then
      move_sel('down')
    end
    if Key.ctrl() and
        k == "home" then
      move_sel('up', nil, true)
    end
    if Key.ctrl() and
        k == "end" then
      move_sel('down', nil, true)
    end

    -- scroll
    if k == "pageup" then
      scroll('up', Key.ctrl())
    end
    if k == "pagedown" then
      scroll('down', Key.ctrl())
    end
  end

  submit()
  load()
  delete()
  navigate()
end
