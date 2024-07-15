--- @class Empty
--- @field tag 'empty'
--- @field line integer
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
    line = ln,
  }, Empty)

  return self
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
--- @param hl SyntaxColoring?
--- @return Chunk
function Chunk.new(lines, hl, pos)
  local ls = (function()
    if type(lines) == 'string' then return { lines } end
    return lines
  end)()
  local self = setmetatable({
    tag = 'chunk',
    lines = ls,
    hl = hl,
    pos = pos,
  }, Chunk)

  return self
end
