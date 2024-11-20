local class = require('util.class')

--- @class Dequeue<T>: { [integer]: T }
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
Dequeue = class.create()

local tags = {}

--- Create a new double-ended queue
--- @param values table?
--- @param tag string? -- define type if created empty
--- @return Dequeue
function Dequeue.new(values, tag)
  local ttag
  if tag then
    ttag = tag or ''
  elseif values
      and type(values) == 'table'
  then
    if
        type(values[1]) == 'table'
    then
      local fv = values[1]
      ttag = fv.tag or type(fv) or ''
    else
      ttag = type(values[1])
    end
  end

  local mt = Dequeue
  local self = setmetatable({}, mt)
  if values and type(values) == 'table' then
    for _, v in ipairs(values) do
      self:push_back(v)
    end
  end
  local addr = tostring(self)
  tags[addr] = ttag
  return self
end

--- @param tag string
--- @param values table?
--- @return Dequeue
function Dequeue.typed(tag, values)
  return Dequeue.new(values, tag)
end

--- Return a string representation
--- @return string
function Dequeue:repr()
  local res = '['
  for i, v in ipairs(self) do
    res = res .. i .. ': ' .. tostring(v) .. ',\n'
  end
  res = res .. ']'
  return res
end

--- Return item type
--- @return string?
function Dequeue:type()
  return tags[tostring(self)]
end

function Dequeue:get_type()
  return self:type()
end

--- @param i integer
--- @param add boolean
--- @return boolean
--- @return string? errmsg
function Dequeue:is_valid(i, add)
  if not i then return false, 'undefined' end
  if i < 1 then return false, 'Index out of bounds (lower)' end
  local l = self:length()
  local u = (function()
    if add then
      return l + 1
    end
    return l
  end)()
  if i > u then return false, 'Index out of bounds (higher)' end
  return true
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
--- @param d Dequeue -- <T>
function Dequeue:append_all(d)
  for _, v in ipairs(d) do
    self:push_back(v)
  end
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

--- @private
--- @param i integer
--- @param add boolean
--- @param f function
--- @return boolean
--- @return string? errmsg
function Dequeue:_checked(i, add, f)
  local ok, err = self:is_valid(i, add)

  if ok then f() end
  return ok, err
end

--- Insert element at index
--- @param v any
--- @param i integer
function Dequeue:insert(v, i)
  self:_checked(i, true, function()
    table.insert(self, i, v)
  end)
end

--- Update element at index
--- @param v any
--- @param i integer
function Dequeue:update(v, i)
  self:_checked(i, false, function()
    self[i] = v
  end)
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
