require("model/inputModel")
require("model/canvasModel")

Console = {}

function Console:new()
  local c = {
    input = InputModel:new(),
    canvas = CanvasModel:new(),
  }
  setmetatable(c, self)
  self.__index = self
  return c
end
