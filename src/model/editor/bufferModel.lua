--- @class BufferModel
--- @field name string
--- @field content Content
--- @field selection Selected[]
BufferModel = {}
BufferModel.__index = BufferModel

setmetatable(BufferModel, {
  __call = function(cls, ...)
    return cls.new(...)
  end,
})

--- @param name string
--- @param content string[]?
function BufferModel.new(name, content)
  local self = setmetatable({
    name = name or 'untitled',
    content = content,
    selected = {},
  }, BufferModel)

  return self
end

function BufferModel:get_content()
  return self.content or {}
end
