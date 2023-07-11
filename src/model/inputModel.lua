local utf8 = require("utf8")

local _ = require("model/textEval")
local _ = require("util/dequeue")

InputModel = {}

function InputModel:new()
  local im = {
    entered = '',
    history = Dequeue:new(),
    evaluator = TextEval:new(),
    cursor = { c = 1, l = 1 }
  }
  setmetatable(im, self)
  self.__index = self

  return im
end

function InputModel:remember(input)
  if input and input ~= '' then
    self.history:push(input)
  end
end

function InputModel:addText(text)
  if type(text) == 'string' then
    -- TODO: multiline
    local ent = self.entered
    local t = ent .. text
    self.entered = t
    self:updateCursor()
  end
end

function InputModel:updateCursor()
  local t = self.entered
  self.cursor.c = utf8.len(t) + 1
end

function InputModel:paste(text)
  self:addText(text)
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
  self:updateCursor()
end

function InputModel:clear()
  self.entered = ''
  self:updateCursor()
end

function InputModel:getStatus()
  return {
    inputType = self.evaluator.kind,
    cursor = self.cursor,
  }
end

function InputModel:evaluate()
  return self:_handle(true)
end

function InputModel:_handle(eval)
  local ent = self.entered
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
