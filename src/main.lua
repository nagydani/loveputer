local _ = require("model/counter")
local _ = require("view/consoleView")
local _ = require("controller/counterController")

function love.load()
  local hidpi = os.getenv("HIDPI")
  if hidpi == 'true' or hidpi == 'TRUE' then
    _G.hiDPI = true
  end

  M = Counter:new()
  C = CounterController:new(M)
  V = ConsoleView:new(M, {
    fontSize = 24
  })
end

function love.update(dt)
  C:increment()
end

function love.draw()
  V:draw()
end
