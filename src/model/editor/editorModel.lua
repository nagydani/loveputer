require("model.editor.bufferModel")
require("model.interpreter.interpreterModel")

local class = require('util.class')

--- @class EditorModel
--- @field interpreter InterpreterModel
--- @field buffer BufferModel?
--- @field cfg Config
EditorModel = class.create(function(cfg)
  return {
    interpreter = InterpreterModel(cfg),
    buffer = nil,
    cfg = cfg,
  }
end)
