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

function Console:evaluate()
  local ent = self.input.entered
  if ent ~= '' then
    local inputText = self.input.entered
    self.input:remember(inputText)
    local result = self.input.evaluator.apply(inputText)
    if result and result ~= '' then
      self.canvas:push(result)
    end
    self.input:clear()
  end
end
