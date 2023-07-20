TerminalTest = {}

function TerminalTest:new(ctrl)
  setmetatable({}, self)
  self.__index = self

  return self
end

function TerminalTest:test(canvas)
  canvas:_manipulate({
    'print("test")',
  })
end
