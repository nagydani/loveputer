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
