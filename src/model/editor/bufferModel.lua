--- @class BufferModel
BufferModel = {}
BufferModel.__index = BufferModel

setmetatable(BufferModel, {
  __call = function(cls, ...)
    return cls.new(...)
  end,
})

--- @param cfg Config
function BufferModel.new(cfg)
  local self = setmetatable({
  }, BufferModel)

  return self
end
