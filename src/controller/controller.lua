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
      C.input:textinput(t)
    end
  end,

  -- mouse
  set_love_mousepressed = function()
    --- @diagnostic disable-next-line: duplicate-set-field
    function love.mousepressed(x, y, button)
      C.input:mousepressed(x, y, button)
    end
  end,
  set_love_mousereleased = function()
    --- @diagnostic disable-next-line: duplicate-set-field
    function love.mousereleased(x, y, button)
      C.input:mousereleased(x, y, button)
    end
  end,
  set_love_mousemoved = function()
    --- @diagnostic disable-next-line: duplicate-set-field
    function love.mousemoved(x, y, dx, dy)
      C.input:mousemoved(x, y)
    end
  end,

  -- update
  set_love_update = function()
    --- @diagnostic disable-next-line: duplicate-set-field
    function love.update(dt)
      C:pass_time(dt)
    end
  end,

  set_default_handlers = function()
    Controller.set_love_keypressed()
    Controller.set_love_keyreleased()
    Controller.set_love_textinput()

    Controller.set_love_mousemoved()
    Controller.set_love_mousepressed()
    Controller.set_love_mousereleased()

    Controller.set_love_update()
  end,

  --- @param C ConsoleController
  setup_callback_handlers = function(C)

    --- @diagnostic disable-next-line: undefined-field
    love.handlers.keypressed = function(k)
      -- Ensure the user can get back to the console
      if Key.ctrl() and Key.shift() then
        if k == "q" then
          C:quit_project()
        end
      end
    end

    end

    --- @diagnostic disable-next-line: undefined-field
    table.protect(love.handlers)
  end
}
