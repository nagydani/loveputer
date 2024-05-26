require("model.editor.bufferModel")

--- @class EditorModel
--- @field interpreter InterpreterModel
--- @field buffer BufferModel?
--- @field cfg Config
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
    buffer = nil,
    cfg = cfg,
  }, EditorModel)

  return self
end
