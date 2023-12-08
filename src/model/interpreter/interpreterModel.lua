require("model.interpreter.eval.textEval")
require("model.interpreter.eval.luaEval")
require("model.interpreter.eval.inputEval")
require("model.interpreter.item")
require("model.input.inputModel")

require("util.dequeue")
require("util.string")
require("util.debug")

--- @class InterpreterModel
--- @field cfg Config
--- @field input InputModel
--- @field history table
--- @field evaluator table
--- @field luaEval table
--- @field textInput table
--- @field luaInput table
--- @field wrapped_error string[]?
-- methods
--- @field new function
--- @field get_entered_text function
--- @todo
InterpreterModel = {}

--- @return InterpreterModel
--- @param cfg Config
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

    wrapped_error = nil
  }
  setmetatable(im, self)
  self.__index = self

  return im
end

--- @param history boolean?
function InterpreterModel:reset(history)
  if history then
    self.history = Dequeue:new()
  end
  self.input:clear_input()
end

--- @return InputText
function InterpreterModel:get_entered_text()
  return self.input:get_text()
end

----------------
-- evaluation --
----------------

function InterpreterModel:evaluate()
  return self:_handle(true)
end

function InterpreterModel:cancel()
  self:_handle(false)
end

--- @param eval boolean
function InterpreterModel:_handle(eval)
  local ent = self:get_entered_text()
  self.historic_index = nil
  local ok, result
  if string.is_non_empty_string_array(ent) then
    local ev = self.evaluator
    self:_remember(ent)
    if eval then
      ok, result = ev.apply(ent)
      if ok then
        self.input:clear_input()
      else
        local l, c, err = self:get_eval_error(result)
        self.input:move_cursor(l, c + 1)
        self.error = err
      end
    else
      self.input:clear_input()
      ok = true
    end
  end
  return ok, result
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

--- @param error string?
--- @param is_call_error boolean
function InterpreterModel:set_error(error, is_call_error)
  if string.is_non_empty_string(error) then
    self.error = error
    self.wrapped_error = string.wrap_at(error, self.input.wrap)
    if not is_call_error then
      self:history_back()
    end
  end
end

function InterpreterModel:get_eval_error(errors)
  local ev = self.evaluator
  local t = self:get_entered_text()
  if string.is_non_empty_string_array(t) then
    return ev.parser.get_error(errors)
  end
end

----------------
--  history   --
----------------

--- @param input string[]
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
      self.input:_set_text(prev, false)
      self.historic_index = hi - 1
      self.input:jump_end()
    end
  else
    self.historic_index = self.history:get_last_index()
    self:_remember(ent)
    local prev = self.history[self.historic_index] or ''
    self.input:_set_text(prev, false)
    self.input:jump_end()
  end
  self.input:clear_selection()
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
      self.input:_set_text(next, false)
      self.historic_index = hi + 1
    else
      self.input:clear_input()
    end
  else
    self:cancel()
  end
  self.input:jump_end() -- TODO: remember cursor pos?
  self.input:clear_selection()
end

--- @return integer
function InterpreterModel:_get_history_length()
  return #(self.history)
end

--- @param i integer
function InterpreterModel:_get_history_entry(i)
  return self.history[i]
end

function InterpreterModel:_get_history_entries()
  return self.history:items()
end
