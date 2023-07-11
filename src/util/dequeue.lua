Dequeue = {}

function Dequeue:new()
  local q = {}
  setmetatable(q, self)
  self.__index = self
  return q
end

function Dequeue:push(l)
  table.insert(self, l)
end

function Dequeue:get_last_index(l)
  return #self
end
