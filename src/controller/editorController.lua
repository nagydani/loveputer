require("model.interpreter.eval.evaluator")
require("controller.inputController")
require("controller.userInputController")
require("view.input.customStatus")

local class = require('util.class')

--- @param M EditorModel
local function new(M)
  return {
    input = UserInputController(M.input, nil, true),
    model = M,
    view = nil,
    mode = 'edit',
  }
end

--- @alias EditorMode
--- | 'edit' --- default
--- | 'reorder'

--- @class EditorController
--- @field model EditorModel
--- @field input UserInputController
--- @field view EditorView?
--- @field mode EditorMode
---
--- @field open function
--- @field get_state function
--- @field set_state function
--- @field save_state function
--- @field restore_state function
--- @field get_clipboard function
--- @field set_clipboard function
--- @field close function
--- @field get_active_buffer function
--- @field get_input function
--- @field update_status function
--- @field textinput function
--- @field keypressed function
EditorController = class.create(new)


--- @param name string
--- @param content string[]?
--- @param save function
function EditorController:open(name, content, save)
  local w = self.model.cfg.view.drawableChars
  local is_lua = string.match(name, '.lua$')
  local ch, hl, pp
  if is_lua then
    self.input:set_eval(LuaEditorEval)
    local luaEval = LuaEval()
    local parser = luaEval.parser
    if not parser then return end
    hl = parser.highlighter
    --- @param t string[]
    --- @param single boolean
    ch = function(t, single)
      return parser.chunker(t, w, single)
    end
    pp = function(t)
      return parser.pprint(t, w)
    end
  else
    self.input:set_eval(TextEval)
  end

  local b = BufferModel(name, content, save, ch, hl, pp)
  self.model.buffer = b
  self.view.buffer:open(b)
  self:update_status()
  self:set_state()
end

--- @return EditorState
function EditorController:get_state()
  return self.state
end

--- @param clipboard string
function EditorController:set_clipboard(clipboard)
  self.state.clipboard = clipboard
end

--- @return string
function EditorController:get_clipboard()
  return self.state.clipboard
end

--- @param clipboard string?
function EditorController:set_state(clipboard)
  self.state = {
    buffer = self.view.buffer:get_state(),
  }
  if clipboard then self:set_clipboard(clipboard) end
end

function EditorController:save_state()
  self:set_state(love.system.getClipboardText())
end

--- @param state EditorState?
function EditorController:restore_state(state)
  if state then
    local buf = self:get_active_buffer()
    local sel = state.buffer.selection
    local off = state.buffer.offset
    buf:set_selection(sel)
    self.view.buffer:scroll_to(off)
    local clip = state.clipboard
    if string.is_non_empty_string(clip) then
      love.system.setClipboardText(clip)
    end
  end
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

--- @return InputDTO
function EditorController:get_input()
  return self.input:get_input()
end

--- @param buf BufferModel
function EditorController:save(buf)
  local ok, err = buf:save()
  if not ok then Log.error("can't save: ", err) end
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
  local input          = self.input
  local is_empty       = input:is_empty()
  local at_limit_start = input:is_at_limit('up')
  local at_limit_end   = input:is_at_limit('down')
  local passthrough    = true
  local block_input    = function() passthrough = false end
  --- @type BufferModel
  local buf            = self:get_active_buffer()

  --- @param dir VerticalDir
  --- @param by integer?
  --- @param warp boolean?
  local function move_sel(dir, by, warp)
    if input:has_error() then return end
    local m = self:get_active_buffer():move_selection(dir, by, warp)
    if m then
      self.view.buffer:follow_selection()
      self:update_status()
    end
  end

  local function newline()
    if not Key.ctrl() and Key.shift() and Key.is_enter(k) then
      buf:insert_newline()
      self.view:refresh()
      block_input()
    end
  end

  local function delete_block()
    buf:delete_selected_text()
    self:save(buf)
    self.view:refresh()
  end

  local function paste()
    local t = love.system.getClipboardText()
    input:add_text(t)
  end
  local function copy()
    local t = string.unlines(buf:get_selected_text())
    love.system.setClipboardText(t)
    self:set_clipboard(t)
    block_input()
  end
  local function cut()
    copy()
    delete_block()
  end

  local function copycut()
    if Key.ctrl() then
      if k == "c" or k == "insert" then
        copy()
        block_input()
      end
      if k == "x" then
        cut()
        block_input()
      end
    end
    if Key.shift() then
      if k == "delete" then
        cut()
        block_input()
      end
    end
  end
  local function paste_k()
    if (Key.ctrl() and k == "v")
        or (Key.shift() and k == "insert")
    then
      paste()
      block_input()
    end
  end

  if is_empty then
    newline()
    copycut()
  end

  paste_k()

  --- @param dir VerticalDir
  --- @param warp boolean?
  --- @param by integer?
  local function scroll(dir, warp, by)
    self.view.buffer:scroll(dir, by, warp)
    self:update_status()
  end

  --- @param add boolean?
  local function load_selection(add)
    local buf = self:get_active_buffer()
    local t = buf:get_selected_text()
    if string.is_non_empty(t) then
      buf:set_loaded()
    else
      buf:clear_loaded()
    end
    if add then
      local c = input:get_cursor_info().cursor
      input:add_text(t)
      input:set_cursor(c)
    else
      input:set_text(t)
      input:jump_home()
    end
  end


  --- handlers
  local function submit()
    if not Key.ctrl() and not Key.shift() and Key.is_enter(k) then
      local bufv = self.view.buffer
      local function go(newtext)
        if bufv:is_selection_visible() then
          if buf:loaded_is_sel(true) then
            local _, n = buf:replace_selected_text(newtext)
            buf:clear_loaded()
            self:save(buf)
            input:clear()
            self.view:refresh()
            move_sel('down', n)
            load_selection()
            self:update_status()
          else
            buf:select_loaded()
            bufv:follow_selection()
          end
        else
          bufv:follow_selection()
        end
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
      load_selection(true)
    end
  end
  local function delete()
    if Key.ctrl() then
      if k == "delete"
          or (k == "y" and is_empty) then
        delete_block()
        block_input()
      end
    end
  end
  local function navigate()
    -- move selection
    if Key.ctrl() then
      if k == "up" then
        move_sel('up')
        block_input()
      end
      if k == "down" then
        move_sel('down')
        block_input()
      end
      if k == "home" then
        move_sel('up', nil, true)
      end
      if k == "end" then
        move_sel('down', nil, true)
      end
    else
      if k == "up" and at_limit_start then
        move_sel('up')
        block_input()
      end
      if k == "down" and at_limit_end then
        move_sel('down')
        block_input()
      end
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
  local function clear()
    if Key.ctrl() and k == "w" then
      buf:clear_loaded()
      input:clear()
    end
  end

  submit()
  load()
  delete()
  navigate()
  clear()

  if passthrough then
    input:keypressed(k)
  end

  if love.debug then
    if k == 'f5' then
      local bufview = self.view.buffer
      bufview:refresh()
    end
  end
end
