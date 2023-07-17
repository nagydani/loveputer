require("util/dequeue")
require("util/string")

CanvasModel = {}

function CanvasModel:new()
  local cm = {
    result = Dequeue:new(),
  }
  setmetatable(cm, self)
  self.__index = self

  return cm
end

function CanvasModel:push(newResult)
  if StringUtils:is_non_empty_string_array(newResult) then
    self.result:push(newResult)
  end
end
