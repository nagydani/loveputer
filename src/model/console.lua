local _ = require("util/dequeue")
local _ = require("model/eval")

Console = {}

function Console:new(init)
  local c = {
    n = init or 0,
    entered = '',
    history = Dequeue:new(),
    result = Dequeue:new(),
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

function Console:evaluate()
  local ent = self.entered
  if ent ~= '' then
    local input = self.entered
    self.history:push(input)
    self.result = Eval.apply(self.history)
    self.entered = ''
  end
end

function Console:dump_state()
  for k, v in pairs(self) do
    if type(v) == 'table' then
      print('---- ' .. k .. ' ----')
      for k1, v1 in pairs(v) do
        print(k1 .. ': ' .. v1)
      end
    else
      print(k .. ': ' .. v)
    end
  end
end
