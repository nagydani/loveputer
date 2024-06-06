--- @class Dequeue<T> : table
--- @field new function
--- @field push_front function
--- @field prepend function
--- @field push_back function
--- @field append function
--- @field push function
--- @field insert function
--- @field update function
--- @field get function
--- @field remove function
--- @field get_last_index function
--- @field items function
--- @field length function
--- @field is_empty function
Dequeue = {}
Dequeue.__index = Dequeue

setmetatable(Dequeue, {
  __call = function(cls, ...)
    return cls.new(...)
  end,
})

--- Create a new double-ended queue
--- @param values table?
function Dequeue.new(values)
  local self = setmetatable({}, Dequeue)
  if values and type(values) == 'table' then
    for _, v in ipairs(values) do
      self:push_back(v)
    end
  end
  return self
end

--- Insert element at the start, reorganizing the array
--- @param v any
function Dequeue:push_front(v)
  table.insert(self, 1, v)
end

--- Pop element from the start, reorganizing the array
--- @return any? element
function Dequeue:pop_front()
  local e = self:get(1)
  table.remove(self, 1)
  return e
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

--- Pop element from the back
--- @return any? element
function Dequeue:pop_back()
  local l = self:length()
  local e = self:get(l)
  table.remove(self, l)
  return e
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

--- @return any? element
function Dequeue:first()
  return self[1]
end

--- @return any? element
function Dequeue:last()
  return self:get(self:length())
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
