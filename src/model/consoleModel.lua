require("model/inputModel")
require("model/canvasModel")

Console = {}

function Console:new(cfg)
  local c = {
    input = InputModel:new(),
    output = CanvasModel:new(cfg),
  }
  setmetatable(c, self)
  self.__index = self
  return c
end
