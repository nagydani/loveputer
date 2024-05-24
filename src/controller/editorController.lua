--- @class EditorController
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
  }, EditorController)

  return self
end

--- @param name string
--- @param content string[]?
function EditorController:open(name, content)
  -- open buffer
end

--- @return string[]
function EditorController:close()
  -- close buffer, return content
  return {}
end
