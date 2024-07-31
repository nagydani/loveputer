require("util.range")

--- @class Empty
--- @field tag 'empty'
--- @field pos Range
Empty = {}
setmetatable(Empty, {
  __call = function(cls, ...)
    return cls.new(...)
  end,
})

--- @param ln integer
--- @return Empty
function Empty.new(ln)
  local self = setmetatable({
    tag = 'empty',
    pos = Range.singleton(ln),
  }, Empty)

  return self
end

function Empty:__tostring()
  return string.format('L%d: <empty>', self.pos.start)
end

--- @class Chunk
--- @field tag 'chunk'
--- @field lines string[]
--- @field hl SyntaxColoring
--- @field pos Range
Chunk = {}
Chunk.__index = Chunk

setmetatable(Chunk, {
  __call = function(cls, ...)
    return cls.new(...)
  end,
})

--- @param lines string|string[]
--- @return Chunk
function Chunk.new(lines, pos)
  local ls = (function()
    if type(lines) == 'string' then return { lines } end
    return lines
  end)()
  local self = setmetatable({
    tag = 'chunk',
    lines = ls,
    pos = pos,
  }, Chunk)

  return self
end

function Chunk:__tostring()
  local ret = ''
  for i, l in ipairs(self.lines) do
    ret = ret .. string.format('\nL%d:\t%s',
      self.pos.start + i - 1, l)
  end
  return ret
end
