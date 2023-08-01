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

function Dequeue:get_last_index()
  return #self
end

function Dequeue:items()
  local i = {}
  for _, v in ipairs(self) do
    table.insert(i, v)
  end
  return i
end
