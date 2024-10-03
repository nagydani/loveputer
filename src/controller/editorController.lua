require("model.interpreter.eval.evaluator")
require("controller.inputController")
require("controller.userInputController")
require("view.input.customStatus")

local class = require('util.class')

--- @class EditorController
--- @field model EditorModel
--- @field input UserInputController
--- @field view EditorView?
---
--- @field open fun(self, name: string, content: string[]?)
--- @field close fun(self): string, string[]
--- @field get_active_buffer fun(self): BufferModel
--- @field update_status function
--- @field textinput fun(self, string)
--- @field keypressed fun(self, string)
EditorController = class.create()

--- @param M EditorModel
function EditorController.new(M)
  local self = setmetatable({
    input = UserInputController(M.input),
    model = M,
    view = nil,
  }, EditorController)

  return self
end

--- @param name string
--- @param content string[]?
function EditorController:open(name, content)
  local w = self.model.cfg.view.drawableChars
  local is_lua = string.match(name, '.lua$')
  if is_lua then
    self.input:set_eval(LuaEditorEval)
  else
    self.input:set_eval(TextEval)
  end
  local ch, hl, pp = (function()
    if is_lua then
      local luaEval = LuaEval()
      local parser = luaEval.parser
      if not parser then return end
      --- @param t string[]
      --- @param single boolean
      local ch = function(t, single)
        return parser.chunker(t, w, single)
      end
      local pp = function(t)
        return parser.pprint(t, w)
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
--- @return Dequeue content
function EditorController:close()
  local buf = self:get_active_buffer()
  self.input:clear()
  local content = buf:get_text_content()
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
    cs = CustomStatus(bufview.content_type, len, more, sel)
  end
  if bufview.content_type == 'lua' then
    local range = bufview.content:get_block_app_pos(sel)
    cs = CustomStatus(
      bufview.content_type, len, more, sel, range)
  end

  return cs
end

function EditorController:update_status()
  local sel = self:get_active_buffer():get_selection()
  local cs = self:_generate_status(sel)
  self.input:set_custom_status(cs)
end

--- @param t string
function EditorController:textinput(t)
  local input = self.model.input
  if input:has_error() then
    input:clear_error()
  else
    if Key.ctrl() and Key.shift() then
      return
    end
    self.input:textinput(t)
  end
end

function EditorController:get_input()
  return self.input:get_input()
end

--- @param go fun(nt: string[]|Block[])
function EditorController:_handle_submit(go)
  local inter = self.input
  local raw = inter:get_text()

  local buf = self:get_active_buffer()
  local ct = buf.content_type
  if ct == 'lua' then
    if not string.is_non_empty_string_array(raw) then
      local sel = buf:get_selection()
      local block = buf:get_content():get(sel)
      if not block then return end
      local ln = block.pos.start
      if ln then go({ Empty(ln) }) end
    else
      local pretty = buf.printer(raw)
      if pretty then
        inter:set_text(pretty)
      else
        --- fallback to original in case of unparse-able input
        pretty = raw
      end
      local ok, res = inter:evaluate()
      local _, chunks = buf.chunker(pretty, true)
      if ok then
        go(chunks)
      else
        local eval_err = res
        if eval_err then
          inter:set_error(eval_err)
        end
      end
    end
  else
    go(raw)
  end
end

--- @param k string
function EditorController:keypressed(k)
  local inter = self.input

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
        local buf = self:get_active_buffer()
        local _, n = buf:replace_selected_text(newtext)
        inter:clear()
        self.view:refresh()
        move_sel('down', n)
        load_selection()
        self:update_status()
      end

      self:_handle_submit(go)
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

  if love.debug then
    if k == 'f5' then
      local bufview = self.view.buffer
      bufview:refresh()
    end
  end
end
