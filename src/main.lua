local _ = require("model/consoleModel")
local _ = require("view/consoleView")
local _ = require("controller/consoleController")

function love.load()
  love.keyboard.setTextInput(true)
  love.keyboard.setKeyRepeat(true)

  M = Console:new()
  C = ConsoleController:new(M)
  V = ConsoleView:new(M, {
    fontSize = 18
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

function love.resize(w, h)
  V:resize(w, h)
end
