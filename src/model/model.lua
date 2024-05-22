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
Model.__index = Model

setmetatable(Model, {
  __call = function(cls, ...)
    return cls.new(...)
  end,
})

--- @param cfg Config
function Model.new(cfg)
  local self = setmetatable({
    interpreter = InterpreterModel(cfg),
    editor = EditorModel(cfg),
    output = CanvasModel(cfg),
    projects = ProjectService:new(),
    cfg = cfg
  }, Model)
  return self
end
