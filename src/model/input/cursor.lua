local class = require('util.class')

--- @class Cursor
--- @field l number
--- @field c number
Cursor = class.create(function(l, c)
  local ll = l or 1
  local cc = c or 1
  return { l = ll, c = cc }
end)

function Cursor:__tostring()
  return string.format('{l%d, %d}', self.l, self.c)
end

function Cursor.inline(c)
  return Cursor(1, c)
end

function Cursor:compare(other)
  if other and other.l and other.c then
    if self.l > other.l then
      return -1
    elseif self.l < other.l then
      return 1
    else
      if self.c > other.c then
        return -1
      elseif self.c < other.c then
        return 1
      else
        return 0
      end
    end
  end
end

function Cursor:is_before(other)
  if other and other.l and other.c then
    return 0 < self:compare(other)
  else
    return false
  end
end

function Cursor:is_after(other)
  if other and other.l and other.c then
    return 0 > self:compare(other)
  else
    return false
  end
end
