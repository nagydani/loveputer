local utf8 = require("utf8")

require("model/textEval")
require("util/dequeue")
require("util/string")

InputModel = {}

function InputModel:new()
  local im = {
    entered = { '' },
    history = Dequeue:new(),
    evaluator = TextEval:new(),
    cursor = { c = 1, l = 1 },
  }
  setmetatable(im, self)
  self.__index = self

  return im
end

function InputModel:remember(input)
  if StringUtils.is_non_empty_string_array(input) then
    self.history:push(input)
  end
end

function InputModel:add_text(text)
  if type(text) == 'string' then
    local cl, cc = self:get_cursor_pos()
    -- TODO: multiline
    local line = self:get_text_line(cl)
    local pre, post = StringUtils.split_at(line, cc)
    local nval = pre .. text .. post
    self:set_text_line(nval, cl, true)
    self:advance_cursor(StringUtils.len(text))
  end
end

function InputModel:set_text(text, keep_cursor)
  if type(text) == 'string' then
    -- TODO: multiline
    self.entered = { text }
    if not keep_cursor then
      self:update_cursor(true)
    end
  end
end

function InputModel:set_text_line(text, ln, keep_cursor)
  if type(text) == 'string' then
    -- TODO: multiline
    self.entered[ln] = text
    if not keep_cursor then
      self:update_cursor(true)
    end
  end
end

function InputModel:get_text()
  return self.entered or { '' }
end

function InputModel:get_text_line(l)
  return self.entered[l]
end

function InputModel:get_current_line()
  local cl = self:get_cursor_y() or 1
  return self.entered[cl]
end

function InputModel:update_cursor(replace_line)
  local cl = self:get_cursor_y()
  local t = self:get_text()
  if replace_line then
    self.cursor.c = utf8.len(t[cl]) + 1
    self.cursor.l = #t
  else

  end
end

function InputModel:advance_cursor(n)
  local cur = self.cursor.c
  local move = n or 1
  local next = cur + move
  self.cursor.c = next
  -- TODO multiline
end

-- TODO: look up a non-retarded synonym
function InputModel:retreat_cursor()
  local cl, cc = self:get_cursor_pos()
  local next = cc - 1
  if cc > 1 then
    self.cursor.c = next
  elseif cl > 1 then
    -- TODO multiline
    local cpl = cl - 1
    local pl = self:get_text_line(cpl)
    local cpc = #pl + 1
    self.cursor.l = cpl
    self.cursor.c = cpc
  end
end

function InputModel:paste(text)
  self:add_text(text)
end

function InputModel:backspace()
  local line = self:get_current_line()
  local cl, cc = self:get_cursor_pos()
  if cc == 1 then
    -- TODO: multiline
    if cl == 1 then return end
  end

  local pre = StringUtils.utf8_sub(line, 1, cc - 2)
  local post = StringUtils.utf8_sub(line, cc)
  local nval = pre .. post
  self:set_text_line(nval, cl, true)
  self:retreat_cursor()
end

function InputModel:delete()
  local line = self:get_current_line()
  local cl, cc = self:get_cursor_pos()
  -- TODO: multiline
  local pre = StringUtils.utf8_sub(line, 1, cc - 1)
  local post = StringUtils.utf8_sub(line, cc + 1)
  local nval = pre .. post
  self:set_text_line(nval, cl, true)
end

function InputModel:get_cursor_pos()
  return self.cursor.l, self.cursor.c
end

function InputModel:get_cursor_x()
  return self.cursor.c
end

function InputModel:get_cursor_y()
  return self.cursor.l
end

function InputModel:cursor_up()
  -- TODO move when multiline
  self:history_back()
end

function InputModel:cursor_down()
  -- TODO move when multiline
  self:history_fwd()
end

function InputModel:cursor_left()
  self:retreat_cursor()
end

function InputModel:cursor_right()
  local cl, cc = self:get_cursor_pos()
  local line = self:get_text_line(cl)
  local len = utf8.len(line)
  local next = cc + 1
  if cc <= len then
    self.cursor.c = next
    -- TODO multiline overflow
  end
end

function InputModel:clear()
  self:set_text('')
  self:update_cursor(true)
  self.historic_index = nil
end

function InputModel:get_status()
  return {
    input_type = self.evaluator.kind,
    cursor = self.cursor,
  }
end

function InputModel:evaluate()
  return self:_handle(true)
end

function InputModel:cancel()
  self:_handle(false)
end

function InputModel:_handle(eval)
  local ent = self:get_text()
  self.historic_index = nil
  local result
  if not StringUtils.is_non_empty_string_array(ent) then
    self:remember(ent)
    if eval then
      result = self.evaluator.apply(ent)
    end
    self:clear()
  end
  return result
end

function InputModel:history_back()
  local ent = self:get_text()
  if self.historic_index then
    local hi = self.historic_index
    local prev = self.history[hi - 1]
    if prev then
      local current = self:get_text()
      if StringUtils.is_non_empty_string(current) then
        self.history[hi] = current
      end
      self:set_text(prev)
      self.historic_index = hi - 1
    end
  else
    self.historic_index = self.history:get_last_index()
    self:remember(ent)
    self:set_text(self.history[self.historic_index])
  end
end

function InputModel:history_fwd()
  if self.historic_index then
    local hi = self.historic_index
    local next = self.history[hi + 1]
    local current = self:get_text()
    if StringUtils.is_non_empty_string(current) then
      self.history[hi] = current
    end
    if next then
      self:set_text(next)
      self.historic_index = hi + 1
    else
      self:clear()
    end
  else
    self:cancel()
  end
  self:update_cursor(true)
end

function InputModel:jump_home()
  self.cursor = { c = 1, l = 1 }
end

function InputModel:jump_end()
  -- TODO multiline
  local ent = self:get_text()
  local last_line = #ent
  local last_char = utf8.len(ent[last_line]) + 1
  self.cursor = { c = last_char, l = last_line }
end
