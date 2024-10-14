require("model.editor.bufferModel")
require("model.interpreter.interpreterModel")
require("model.input.userInputModel")

local class = require('util.class')

--- @class EditorModel
--- @field input UserInputModel
--- @field buffer BufferModel?
--- @field cfg Config
EditorModel = class.create(function(cfg)
  return {
    input = UserInputModel(cfg),
    buffer = nil,
    cfg = cfg,
  }
end)
