Dequeue = {}

--- Create a new double-ended queue
--- @param values table?
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

--- Insert element at the start, reorganizing the array
--- @param v any
function Dequeue:push_front(v)
  table.insert(self, 1, v)
end

--- Insert element at the start, reorganizing the array
--- @param v any
function Dequeue:prepend(v)
  self:push_front(v)
end

--- Insert element at the end
--- @param v any
function Dequeue:push_back(v)
  table.insert(self, v)
end

--- Insert element at the end
--- @param v any
function Dequeue:append(v)
  self:push_back(v)
end

--- Insert element at the end
--- @param v any
function Dequeue:push(v)
  self:push_back(v)
end

--- Insert element at index
--- @param v any
--- @param i integer
function Dequeue:insert(v, i)
  -- TODO: bounds check
  table.insert(self, i, v)
end

--- Update element at index
--- @param v any
--- @param i integer
function Dequeue:update(v, i)
  -- TODO: bounds check
  self[i] = v
end

--- Get element at index
--- @param i integer
--- @return any? element
function Dequeue:get(i)
  return self[i]
end

--- Remove element at index
--- Note: this reorganizes the contents
--- @param i integer
function Dequeue:remove(i)
  table.remove(self, i)
end

--- Get index of last element [equivalent to length()]
--- @return integer
function Dequeue:get_last_index()
  return #self
end

--- Return all elements in the queue
--- Note: this creates a shallow clone
--- @return table
function Dequeue:items()
  local t = {}
  for _, v in ipairs(self) do
    table.insert(t, v)
  end
  return t
end

--- Get queue length
--- @return integer
function Dequeue:length()
  return #self
end

--- Determine if queue is empty
--- @return boolean
function Dequeue:is_empty()
  return self:length() == 0
end
