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
  local IC = InputController(M.interpreter.input)
  local self = setmetatable({
    interpreter = InterpreterController(M.interpreter, IC),
    model = M,
    view = nil,
  }, EditorController)

  return self
end

--- @param name string
--- @param content string[]?
function EditorController:open(name, content)
  local interM = self.model.interpreter
  local is_lua = string.match(name, '.lua$')
  if is_lua then
    self.interpreter:set_eval(interM.luaInput)
  else
    self.interpreter:set_eval(interM.textInput)
  end
  local ch, hl, pp = (function()
    if is_lua then
      local luaEval = LuaEval.new()
      local parser = luaEval.parser
      --- @param t string[]
      --- @param single boolean
      local ch = function(t, single)
        return parser.chunker(t,
          self.model.cfg.view.drawableChars,
          single)
      end
      local pp = function(t)
        return parser.pprint(t,
          self.model.cfg.view.drawableChars)
      end
      return ch, parser.highlighter, pp
    end
  end)()

  local b = BufferModel(name, content, ch, hl, pp)
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
--- @param sel integer
--- @return CustomStatus
function EditorController:_generate_status(sel)
  --- @type BufferModel
  local buffer = self:get_active_buffer()
  local len = buffer:get_content_length() + 1
  local bufview = self.view.buffer
  local more = bufview.content:get_more()
  local cs
  if bufview.content_type == 'plain' then
    cs = {
      content_type = bufview.content_type,
      line = sel,
      buflen = len,
      buffer_more = more,
    }
    cs.__tostring = function(t)
      return 'L' .. t.line
    end
  end
  if bufview.content_type == 'lua' then
    local range = bufview.content:get_block_pos(sel)
    cs = {
      content_type = bufview.content_type,
      block = sel,
      range = range,
      buflen = len,
      buffer_more = more,
    }
    cs.__tostring = function(t)
      return 'B' .. t.range
    end
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
  local inter = self.interpreter

  local vmove = inter:keypressed(k)

  --- @param dir VerticalDir
  --- @param by integer?
  --- @param warp boolean?
  local function move_sel(dir, by, warp)
    if inter:has_error() then return end
    local m = self:get_active_buffer():move_selection(dir, by, warp)
    if m then
      inter:clear()
      self.view.buffer:follow_selection()
      self:update_status()
    end
  end

  --- @param dir VerticalDir
  --- @param warp boolean?
  --- @param by integer?
  local function scroll(dir, warp, by)
    self.view.buffer:scroll(dir, by, warp)
    self:update_status()
  end

  local function load_selection()
    local t = self:get_active_buffer():get_selected_text()
    inter:set_text(t)
  end


  --- handlers
  local function submit()
    if not Key.ctrl() and not Key.shift() and Key.is_enter(k) then
      local function go(newtext)
        local _, n = self:get_active_buffer()
            :replace_selected_text(newtext)
        inter:clear()
        self.view:refresh()
        move_sel('down', n)
        load_selection()
        self:update_status()
      end

      local ct = self:get_active_buffer().content_type
      if ct == 'lua' then
        local buf = self:get_active_buffer()
        local raw = self.interpreter:get_text()
        local pretty = buf.printer(raw)
        local ok, res = inter:evaluate()
        local _, chunks = buf.chunker(pretty, true)
        if ok then
          go(chunks)
        else
          local _, _, eval_err = inter:get_eval_error(res)
          inter:set_error(eval_err)
          inter:history_back()
        end
      else
        go(self.interpreter:get_text())
      end
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
      inter:add_text(t)
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
    if not Key.shift()
        and k == "pageup" then
      scroll('up', Key.ctrl())
    end
    if not Key.shift()
        and k == "pagedown" then
      scroll('down', Key.ctrl())
    end
    if Key.shift()
        and k == "pageup" then
      scroll('up', false, 1)
    end
    if Key.shift()
        and k == "pagedown" then
      scroll('down', false, 1)
    end
  end

  submit()
  load()
  delete()
  navigate()
end
