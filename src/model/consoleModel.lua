require("model/inputModel")
require("model/canvasModel")

Console = {}

function Console:new(cfg)
  local c = {
    input = InputModel:new(cfg),
    output = CanvasModel:new(cfg),
  }
  setmetatable(c, self)
  self.__index = self
  return c
end
