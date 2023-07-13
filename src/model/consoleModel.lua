require("model/inputModel")
require("model/canvasModel")

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
