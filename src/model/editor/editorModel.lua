require("model.editor.bufferModel")

--- @class EditorModel
--- @field interpreter InterpreterModel
--- @field buffer BufferModel
EditorModel = {}
EditorModel.__index = EditorModel

setmetatable(EditorModel, {
  __call = function(cls, ...)
    return cls.new(...)
  end,
})

--- @param cfg Config
function EditorModel.new(cfg)
  local self = setmetatable({
    interpreter = InterpreterModel(cfg), -- EditorInterpreter?
    buffer = BufferModel(),
  }, EditorModel)

  return self
end
