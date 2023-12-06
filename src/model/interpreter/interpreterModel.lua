require("model.interpreter.eval.textEval")
require("model.interpreter.eval.luaEval")
require("model.interpreter.eval.inputEval")
require("model.interpreter.item")
require("model.input.inputModel")

require("util.dequeue")
require("util.string")
require("util.debug")

--- @class InterpreterModel
--- @field history table
--- @field evaluator table
--- @field luaEval table
--- @field textInput table
--- @field luaInput table
--- @field input InputModel
-- methods
--- @field get_entered_text function
--- @todo
InterpreterModel = {}

function InterpreterModel:new(cfg)
  local luaEval   = LuaEval:new('metalua')
  local textInput = InputEval:new(false)
  local luaInput  = InputEval:new(true)
  local im        = {
    input = InputModel:new(cfg, luaEval),
    history = Dequeue:new(),
    -- starter
    evaluator = luaEval,
    -- available options
    luaEval = luaEval,
    textInput = textInput,
    luaInput = luaInput,
  }
  setmetatable(im, self)
  self.__index = self

  return im
end

--- @param history boolean
function InterpreterModel:reset(history)
  if history then
    self.history = Dequeue:new()
  end
  self.input:clear_input()
end

--- @return string[]
function InterpreterModel:get_entered_text()
  return self.input:get_text()
end

----------------
-- evaluation --
----------------
function InterpreterModel:get_status()
  return self.input:get_status()
end

function InterpreterModel:evaluate()
  return self:_handle(true)
end

function InterpreterModel:cancel()
  self:_handle(false)
end

function InterpreterModel:_handle(eval)
  local ent = self:get_entered_text()
  self.historic_index = nil
  local ok, result
  if string.is_non_empty_string_array(ent) then
    local ev = self.evaluator
    self:_remember(ent)
    if eval then
      if ev.is_lua then
        ok, result = self.evaluator.apply(ent)

        if ok then
          self.input:clear_input()
        else
          local l, c, err = self:get_eval_error(result)
          self.input:move_cursor(l, c + 1)
          self.error = err
        end
      else
        -- whatever else happens, return to lua interpreter
        if ev.kind == 'input' then
          local t = self:get_entered_text()
          if string.is_non_empty_string_array(t) then
            -- TODO
            -- local kind = (function()
            --   if ev.highlight then return 'lua' else return 'text' end
            -- end)()
            -- self.inputs:push_back(Item:new(t, kind))
          end
        end
        self:switch('lua')
        self.input:clear_input()
      end
    else
      self.input:clear_input()
      ok = true
    end
  end
  return ok, result
end

--- @param kind EvalType
function InterpreterModel:switch(kind)
  local sw = {
    ['lua']        = self.luaEval,
    ['input-text'] = self.textInput,
    ['input-lua']  = self.luaInput,
  }
  local new = sw[kind]
  if new then
    self.evaluator = new
  else
    self:set_error('Invalid choice of eval', true)
  end
end

----------------
--   error    --
----------------
function InterpreterModel:clear_error()
  self.wrapped_error = nil
end

function InterpreterModel:get_wrapped_error()
  return self.wrapped_error
end

function InterpreterModel:has_error()
  return string.is_non_empty_string_array(self.wrapped_error)
end

function InterpreterModel:set_error(error, is_call_error)
  if string.is_non_empty_string(error) then
    self.error = error
    self.wrapped_error = string.wrap_at(error, self.wrap)
    if not is_call_error then
      self:history_back()
    end
  end
end

function InterpreterModel:get_eval_error(errors)
  local ev = self.evaluator
  local t = self:get_entered_text()
  if ev.is_lua and string.is_non_empty_string_array(t) then
    return ev.parser.get_error(errors)
  end
end

----------------
--  history   --
----------------
function InterpreterModel:_remember(input)
  if string.is_non_empty_string_array(input) then
    self.history:append(input)
  end
end

function InterpreterModel:history_back()
  local ent = self:get_entered_text()
  local hi = self.historic_index
  -- TODO: remember cursor pos?
  if hi and hi > 0 then
    local prev = self.history[hi - 1]
    if prev then
      local current = self:get_entered_text()
      if string.is_non_empty_string_array(current) then
        self.history[hi] = current
      end
      self.input:_set_text(prev)
      self.historic_index = hi - 1
      self.input:jump_end()
    end
  else
    self.historic_index = self.history:get_last_index()
    self:_remember(ent)
    local prev = self.history[self.historic_index] or ''
    self.input:_set_text(prev)
    self.input:jump_end()
  end
  self:clear_selection()
end

function InterpreterModel:history_fwd()
  if self.historic_index then
    local hi = self.historic_index
    local next = self.history[hi + 1]
    local current = self:get_entered_text()
    if string.is_non_empty_string_array(current) then
      self.history[hi] = current
    end
    if next then
      self.input:_set_text(next)
      self.historic_index = hi + 1
    else
      self.input:clear_input()
    end
  else
    self:cancel()
  end
  self.input:jump_end() -- TODO: remember cursor pos?
  self:clear_selection()
end

function InterpreterModel:_get_history_length()
  return #(self.history)
end

function InterpreterModel:_get_history_entry(i)
  return self.history[i]
end

function InterpreterModel:_get_history_entries()
  return self.history:items()
end

----------------
-- selection  --
----------------
function InterpreterModel:translate_grid_to_cursor(l, c)
  local wt       = self.wrap_reverse
  local li       = wt[l] or wt[#wt]
  local line     = self:get_wrapped_text_line(l)
  local llen     = string.ulen(line)
  local c_offset = math.min(llen + 1, c)
  local c_base   = l - li
  local ci       = c_base * self.wrap + c_offset
  return li, ci
end

function InterpreterModel:diff_cursors(c1, c2)
  if c1 and c2 then
    local d = c1:compare(c2)
    if d > 0 then
      return c1, c2
    else
      return c2, c1
    end
  end
end

function InterpreterModel:text_between_cursors(from, to)
  if from and to then
    return self:get_entered_text():traverse(from, to)
  else
    return { '' }
  end
end

function InterpreterModel:start_selection(l, c)
  local start = (function()
    if l and c then
      return Cursor:new(l, c)
    else -- default to current cursor position
      return Cursor:new(self:_get_cursor_pos())
    end
  end)()
  self.selection.start = start
end

function InterpreterModel:end_selection(l, c)
  local start         = self.selection.start
  local fin           = (function()
    if l and c then
      return Cursor:new(l, c)
    else -- default to current cursor position
      return Cursor:new(self:_get_cursor_pos())
    end
  end)()
  local from, to      = self:diff_cursors(start, fin)
  local sel           = self:text_between_cursors(from, to)
  self.selection.fin  = fin
  self.selection.text = sel
end

function InterpreterModel:hold_selection(is_mouse)
  if not is_mouse then
    local cur_start = self:get_selection().start
    local cur_end = self:get_selection().fin
    if cur_start and cur_start.l and cur_start.c then
      self:start_selection(cur_start.l, cur_start.c)
    else
      self:start_selection()
    end
    if cur_end and cur_end.l and cur_end.c then
      self:end_selection(cur_end.l, cur_end.c)
    else
      self:end_selection()
    end
  end
  self.selection.held = true
end

function InterpreterModel:release_selection()
  self.selection.held = false
end

function InterpreterModel:get_selection()
  return self.selection
end

function InterpreterModel:is_selection_held()
  return self.selection.held
end

function InterpreterModel:get_selected_text()
  return self.selection.text
end

function InterpreterModel:pop_selected_text()
  local t     = self.input.selection.text
  local start = self.input.selection.start
  local fin   = self.input.selection.fin
  if start and fin then
    local from, to = self:diff_cursors(start, fin)
    self:get_entered_text():traverse(from, to, { delete = true })
    self:text_change()
    self:move_cursor(from.l, from.c)
    self:clear_selection()
    return t
  end
end

function InterpreterModel:clear_selection()
  self.selection = Selection:new()
  self:release_selection()
end

function InterpreterModel:mouse_click(l, c)
  local li, ci = self:translate_grid_to_cursor(l, c)
  self:clear_selection()
  self:start_selection(li, ci)
  self:hold_selection(true)
end

function InterpreterModel:mouse_release(l, c)
  local li, ci = self:translate_grid_to_cursor(l, c)
  self:release_selection()
  self:end_selection(li, ci)
  self:move_cursor(li, ci, 'keep')
end

function InterpreterModel:mouse_drag(l, c)
  local li, ci = self:translate_grid_to_cursor(l, c)
  local sel = self:get_selection()
  if sel.start and sel.held then
    self:end_selection(li, ci)
    self:move_cursor(li, ci, 'move')
  end
end
