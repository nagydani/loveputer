--- @class Cursor
--- @field l number
--- @field c number
Cursor = {
  l = 0,
  c = 0
}

function Cursor:new(l, c)
  local ll = l or 1
  local cc = c or 1
  local cur = { l = ll, c = cc }
  setmetatable(cur, self)
  self.__index = self

  return cur
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
