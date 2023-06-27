local model = require("model/counter")
local view = require("view/counterView")
local controller = require("controller/counterController")

function love.load()
  M = Counter:new()
  C = CounterController:new(M)
  V = CounterView:new(M)
end

function love.update(dt)
  C:increment()
end

function love.draw()
  V:draw()
end
