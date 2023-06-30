local _ = require("model/console")
local _ = require("view/consoleView")
local _ = require("controller/consoleController")

function love.load()
  local hidpi = os.getenv("HIDPI")
  if hidpi == 'true' or hidpi == 'TRUE' then
    _G.hiDPI = true
  end

  M = Console:new()
  C = ConsoleController:new(M)
  V = ConsoleView:new(M, {
    fontSize = 24
  })
end

function love.textinput(t)
  C:textinput(t)
end

function love.keypressed(k)
  C:keypressed(k)
end

function love.update(dt)
  C:increment()
end

function love.draw()
  V:draw()
end
