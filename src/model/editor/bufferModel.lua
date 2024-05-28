--- @alias Content Dequeue

--- @class BufferModel
--- @field name string
--- @field content Content
--- @field selection integer[]
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
  local buffer = Dequeue(content)
  buffer:push_back('EOF')
  local self = setmetatable({
    name = name or 'untitled',
    content = buffer,
    selection = { #buffer },
  }, BufferModel)

  return self
end

function BufferModel:get_content()
  return self.content or {}
end
