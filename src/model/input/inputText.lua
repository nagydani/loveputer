require("util.dequeue")

InputText = {}
function InputText:new(values)
  local text = Dequeue:new(values)
  if not values or values == '' then
    text:append('')
  end
  setmetatable(self, Dequeue)
  setmetatable(text, self)
  self.__index = self

  return text
end
