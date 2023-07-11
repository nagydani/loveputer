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
  self.history:push(input)
end

function InputModel:addText(text)
  if type(text) == 'string' then
    -- TODO: multiline
    local ent = self.entered
    local t = ent .. text
    self.cursor.c = #t
    self.entered = t
  end
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
end

function InputModel:clear()
  self.cursor = { c = 1, l = 1 }
  self.entered = ''
end

function InputModel:getStatus()
  return {
    inputType = self.evaluator.kind,
    cursor = self.cursor,
  }
end
