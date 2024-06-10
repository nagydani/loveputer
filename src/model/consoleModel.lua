require("model.canvasModel")
require("model.editor.editorModel")
require("model.interpreter.interpreterModel")
require("model.project.project")

--- @class Model table
--- @field interpreter InterpreterModel
--- @field editor EditorModel
--- @field output CanvasModel
--- @field projects ProjectService
--- @field cfg Config
ConsoleModel = {}
ConsoleModel.__index = ConsoleModel

setmetatable(ConsoleModel, {
  __call = function(cls, ...)
    return cls.new(...)
  end,
})

--- @param cfg Config
function ConsoleModel.new(cfg)
  local self = setmetatable({
    interpreter = InterpreterModel(cfg),
    editor      = EditorModel(cfg),
    output      = CanvasModel(cfg),
    projects    = ProjectService:new(),
    cfg         = cfg
  }, ConsoleModel)
  return self
end
