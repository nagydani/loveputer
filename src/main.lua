require("model/consoleModel")
require("view/consoleView")
require("controller/consoleController")

function love.load()
  love.keyboard.setTextInput(true)
  love.keyboard.setKeyRepeat(true)

  M = Console:new()
  C = ConsoleController:new(M)
  V = ConsoleView:new({
    font_size = 18
  }, C)
end

function love.textinput(t)
  C:textinput(t)
end

function love.keypressed(k)
  C:keypressed(k)
end

function love.keyreleased(k)
  local ctrl = love.keyboard.isDown("lctrl", "rctrl")
  -- Ctrl held
  if ctrl then
    if k == "escape" then
      love.event.quit()
    end
  end
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
