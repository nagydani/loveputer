TerminalTest = {}

function TerminalTest:new(ctrl)
  setmetatable({}, self)
  self.__index = self

  return self
end

function TerminalTest:test(canvasM)
  canvasM:_manipulate({
    'love.graphics.setColor(.7, .7, 0)',
    'love.graphics.print("test")',
    'love.graphics.setColor(.7, 0, 0)',
    'love.graphics.rectangle("fill", 30, 40, 150, 200)',
  })
end
