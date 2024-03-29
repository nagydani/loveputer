require("model.interpreter.interpreterModel")
require("model.canvasModel")
require("model.project.project")

--- @class Model table
--- @field interpreter InterpreterModel
--- @field output CanvasModel
--- @field projects ProjectService
Model = {}

--- @param cfg Config
function Model:new(cfg)
  local c = {
    interpreter = InterpreterModel:new(cfg),
    output = CanvasModel:new(cfg),
    projects = ProjectService:new(),
  }
  setmetatable(c, self)
  self.__index = self
  return c
end
