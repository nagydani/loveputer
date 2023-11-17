Controller = {
  -- keyboard
  set_love_keypressed = function()
    --- @diagnostic disable-next-line: duplicate-set-field
    function love.keypressed(k)
      C:keypressed(k)
    end
  end,
  set_love_keyreleased = function()
    --- @diagnostic disable-next-line: duplicate-set-field
    function love.keyreleased(k)
      local ctrl = love.keyboard.isDown("lctrl", "rctrl")
      -- Ctrl held
      if ctrl then
        if k == "escape" then
          love.event.quit()
        end
      end
      C:keyreleased(k)
    end
  end,
  set_love_textinput = function()
    --- @diagnostic disable-next-line: duplicate-set-field
    function love.textinput(t)
      C:textinput(t)
    end
  end,

  -- mouse
  set_love_mousepressed = function()
    --- @diagnostic disable-next-line: duplicate-set-field
    function love.mousepressed(x, y, button)
      C:mousepressed(x, y, button)
    end
  end,
  set_love_mousereleased = function()
    --- @diagnostic disable-next-line: duplicate-set-field
    function love.mousereleased(x, y, button)
      C:mousereleased(x, y, button)
    end
  end,
  set_love_mousemoved = function()
    --- @diagnostic disable-next-line: duplicate-set-field
    function love.mousemoved(x, y, dx, dy)
      C:mousemoved(x, y)
    end
  end,

  set_default_handlers = function()
    Controller.set_love_keypressed()
    Controller.set_love_keyreleased()
    Controller.set_love_textinput()

    Controller.set_love_mousemoved()
    Controller.set_love_mousepressed()
    Controller.set_love_mousereleased()
  end
}
