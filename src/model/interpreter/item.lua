Item = {
  text = '',
  kind = nil,
}

function Item:new(text, kind)
  local i = {
    text = text,
  }
  if kind then
    i.kind = kind
  end
  setmetatable(i, self)
  self.__index = self

  return i
end
