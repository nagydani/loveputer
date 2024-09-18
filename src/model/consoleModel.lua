local class = require('util.class')

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
ConsoleModel = class.create(function(cfg)
  return {
    interpreter = InterpreterModel(cfg),
    editor      = EditorModel(cfg),
    output      = CanvasModel(cfg),
    projects    = ProjectService:new(),
    cfg         = cfg
  }
end)
