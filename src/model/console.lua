Console = {}

function Console:new(init)
  local c = {
    n = init or 0,
    entered = '',
  }
  setmetatable(c, self)
  self.__index = self
  return c
end

function Console:incr()
  self.n = self.n + 1
end

function Console:backspace()
  local t = self.entered
  self.entered = string.sub(t, 1, #t - 1)
end
