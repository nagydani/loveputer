require("model.input.inputModel")
require("model.canvasModel")
require("model.project.project")

--- @class Model table
--- @field input InputModel
--- @field output CanvasModel
--- @field projects ProjectService
Model = {}

function Model:new(cfg)
  local c = {
    input = InputModel:new(cfg),
    output = CanvasModel:new(cfg),
    projects = ProjectService:new(),
  }
  setmetatable(c, self)
  self.__index = self
  return c
end
