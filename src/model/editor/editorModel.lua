--- @class EditorModel
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
    interpreter = InterpreterModel:new(cfg)
  }, EditorModel)

  return self
end
