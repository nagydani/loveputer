require("model.canvasModel")
require("model.editor.editorModel")
require("model.interpreter.interpreterModel")
require("model.project.project")

--- @class Model table
--- @field interpreter InterpreterModel
--- @field output CanvasModel
--- @field projects ProjectService
--- @field cfg Config
Model = {}

--- @param cfg Config
function Model:new(cfg)
  local c = {
    interpreter = InterpreterModel:new(cfg),
    editor = EditorModel.new(cfg),
    output = CanvasModel.new(cfg),
    projects = ProjectService:new(),
    cfg = cfg
  }
  setmetatable(c, self)
  self.__index = self
  return c
end
