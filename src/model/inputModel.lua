local utf8 = require("utf8")

local _ = require("model/textEval")
local _ = require("util/dequeue")
local _ = require("util/string")

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
  if type(text) == 'string' then
    -- TODO: multiline
    local ent = self:get_text()
    local t = ent .. text
    self.entered = t
    self:update_cursor()
  end
end

function InputModel:set_text(text)
  if type(text) == 'string' then
    -- TODO: multiline
    local t = text
    self.entered = t
    self:update_cursor()
  end
end

function InputModel:get_text()
  return self.entered or ''
end

function InputModel:update_cursor()
  local t = self.entered
  self.cursor.c = utf8.len(t) + 1
end

function InputModel:paste(text)
  self:add_text(text)
end

function InputModel:backspace()
  local t = self.entered
  local byteoffset = utf8.offset(t, -1)

  if byteoffset then
    -- remove the last UTF-8 character.
    -- string.sub operates on bytes rather than UTF-8 characters,
    -- so we couldn't do string.sub(text, 1, -2).
    self.entered = string.sub(t, 1, byteoffset - 1)
  else
    self.entered = string.sub(t, 1, #t - 1)
  end
  self:update_cursor()
end

function InputModel:delete()
  local t = self.entered
  local byteoffset = utf8.offset(t, -1)

  if byteoffset then
    -- self.entered = string.sub(t, 1, byteoffset - 1)
  else
    -- self.entered = string.sub(t, 1, #t - 1)
  end
  -- self:update_cursor()
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

end

function InputModel:cursor_right()

end

function InputModel:clear()
  self.entered = ''
  self:update_cursor()
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
      self.entered = next
      self.historic_index = hi + 1
    else
      self:clear()
    end
  else
    self:cancel()
  end
end
