--- @class EditorController
--- @field model EditorModel
--- @field open fun(self, name: string, content: string[]?)
--- @field close fun(self): string[]
EditorController = {}
EditorController.__index = EditorController

setmetatable(EditorController, {
  __call = function(cls, ...)
    return cls.new(...)
  end,
})

--- @param M EditorModel
function EditorController.new(M)
  local self = setmetatable({
    model = M,
  }, EditorController)

  return self
end

--- @param name string
--- @param content string[]?
function EditorController:open(name, content)
  self.model.buffer = BufferModel.new(name, content)
end

--- @return string[]
function EditorController:close()
  -- close buffer, return content
  return {}
end

--- @return BufferModel
function EditorController:get_active_buffer()
  return self.model.buffer
end

