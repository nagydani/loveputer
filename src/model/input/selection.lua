require("model.input.cursor")

Selection = {}

function Selection:new()
  local s = {
    start = Cursor:new(),
    fin = Cursor:new(),
    text = { '' },
    held = false,
  }
  setmetatable(s, self)
  self.__index = self

  return s
end

function Selection:isHeld()
  return self.held
end
