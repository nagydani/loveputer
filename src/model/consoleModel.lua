local _ = require("model/inputModel")
local _ = require("model/canvasModel")
local _ = require("model/eval")

Console = {}

function Console:new(init)
  local c = {
    n = init or 0,
    input = InputModel:new(),
    canvas = CanvasModel:new(),
  }
  setmetatable(c, self)
  self.__index = self
  return c
end

function Console:incr()
  self.n = self.n + 1
end

function Console:paste(text)
  local t = self.input.entered
  self.input.entered = t .. text
end

function Console:evaluate()
  local ent = self.input.entered
  if ent ~= '' then
    local inputText = self.input.entered
    self.input:push(inputText)
    local result = Eval.apply(self.input.entered)
    if result and result ~= '' then
      self.canvas:push(result)
    end
    self.input:clear()
  end
end
