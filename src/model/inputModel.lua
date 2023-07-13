local utf8 = require("utf8")

require("model/textEval")
require("util/dequeue")
require("util/string")

InputModel = {}

function InputModel:new()
  local im = {
    entered = '',
    history = Dequeue:new(),
    evaluator = TextEval:new(),
    cursor = { c = 1, l = 1 },
  }
  setmetatable(im, self)
  self.__index = self

  return im
end

function InputModel:remember(input)
  if StringUtils.is_non_empty_string(input) then
    -- TODO: handle historic input
    self.history:push(input)
  end
end

function InputModel:add_text(text)
  -- TODO: multiline
  local _, pos_x = self:get_cursor_pos()
  if type(text) == 'string' then
    local ent = self:get_text()
    local pre = string.sub(ent, 1, pos_x - 1)
    local post = string.sub(ent, pos_x, #ent)
    local nval = pre .. text .. post
    self.entered = nval
    self:advance_cursor(utf8.len(text))
  end
end

function InputModel:set_text(text, keep_cursor)
  if type(text) == 'string' then
    -- TODO: multiline
    local t = text
    self.entered = t
    if not keep_cursor then
      self:update_cursor(true)
    end
  end
end

function InputModel:get_text()
  return self.entered or ''
end

function InputModel:update_cursor(destructive)
  local t = self.entered
  if destructive then
    self.cursor.c = utf8.len(t) + 1
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
  local cur = self.cursor.c
  local next = cur - 1
  if cur > 1 then
    self.cursor.c = next
    -- TODO multiline
  end
end

function InputModel:paste(text)
  self:add_text(text)
end

function InputModel:backspace()
  -- TODO: multiline
  local ent = self.entered
  local _, pos_x = self:get_cursor_pos()
  local byteoffset = utf8.offset(ent, -1)

  if byteoffset then
    -- remove the last UTF-8 character.
    -- string.sub operates on bytes rather than UTF-8 characters,
    -- so we couldn't do string.sub(text, 1, -2).
    self.entered = string.sub(ent, 1, byteoffset - 1)
  else
    self.entered = string.sub(ent, 1, #ent - 1)
  end
  self:retreat_cursor()
end

function InputModel:delete()
  local ent = self.entered
  local _, pos_x = self:get_cursor_pos()
  local pre = string.sub(ent, 1, pos_x - 1)
  local post = string.sub(ent, pos_x + 1, #ent)
  local nval = pre .. post
  self:set_text(nval, true)
end

function InputModel:get_cursor_pos()
  return self.cursor.l, self.cursor.c
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
  local line = self:get_text()
  local cx = self.cursor.c
  if cx > 1 then
    local prev = StringUtils.to_utf8_index(line, cx - 1)
    self.cursor.c = prev
    -- TODO multiline underflow
  end
end

function InputModel:cursor_right()
  local line = self:get_text()
  local cx = self.cursor.c
  local next = cx + 1
  if cx <= #line then
    self.cursor.c = next
    -- TODO multiline overflow
  end
end

function InputModel:clear()
  self.entered = ''
  self:update_cursor(true)
  self.historic_index = nil
end

function InputModel:get_status()
  return {
    inputType = self.evaluator.kind,
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
  local ent = self.entered
  self.historic_index = nil
  local result
  if ent ~= '' then
    self:remember(ent)
    if eval then
      result = self.evaluator.apply(ent)
    end
    self:clear()
  end
  return result
end

function InputModel:history_back()
  local ent = self.entered
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
    self.entered = self.history[self.historic_index]
  end
  self:update_cursor(true)
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
