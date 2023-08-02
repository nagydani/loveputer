Dequeue = {}

function Dequeue:new(values)
  local q = {}
  setmetatable(q, self)
  self.__index = self
  if values and type(values) == 'table' then
    for _, v in ipairs(values) do
      q:push_back(v)
    end
  end
  return q
end

function Dequeue:push_front(v)
  table.insert(self, 1, v)
end

function Dequeue:prepend(v)
  self:push_front(v)
end

function Dequeue:push_back(v)
  table.insert(self, v)
end

function Dequeue:append(v)
  self:push_back(v)
end

function Dequeue:insert(v, i)
  -- TODO: bounds check
  table.insert(self, i, v)
end

function Dequeue:update(v, i)
  -- TODO: bounds check
  self[i] = v
end

function Dequeue:get(i)
  return self[i]
end

function Dequeue:remove(i)
  table.remove(self, i)
end

function Dequeue:get_last_index()
  return #self
end

function Dequeue:items()
  local t = {}
  for _, v in ipairs(self) do
    table.insert(t, v)
  end
  return t
end

function Dequeue:length(i)
  return #self
end
