require("util.string")

local get_user_input = function()
  return love.state.user_input
end

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
      local ddr = View.prev_draw
      local ldr = love.draw
      if ldr ~= ddr then
        local function draw()
          ldr()
          local user_input = get_user_input()
          if user_input then
            user_input.V:draw(user_input.C:get_input())
          end
        end
        View.prev_draw = draw
        love.draw = draw
      end
      C:pass_time(dt)
    end
  end,

  set_default_handlers = function()
    Controller.set_love_keypressed()
    Controller.set_love_keyreleased()
    Controller.set_love_textinput()
    -- SKIPPED textedited - IME support, TODO?

    Controller.set_love_mousemoved()
    Controller.set_love_mousepressed()
    Controller.set_love_mousereleased()
    -- SKIPPED wheelmoved - TODO

    -- SKIPPED touchpressed  - target device doesn't support touch
    -- SKIPPED touchreleased - target device doesn't support touch
    -- SKIPPED touchmoved    - target device doesn't support touch

    -- SKIPPED joystick and gamepad support

    -- SKIPPED focus       - intented to run as kiosk app
    -- SKIPPED mousefocus  - intented to run as kiosk app
    -- SKIPPED visible     - intented to run as kiosk app

    -- SKIPPED quit        - intented to run as kiosk app
    -- SKIPPED threaderror - no threading support

    -- SKIPPED resize           - intented to run as kiosk app
    -- SKIPPED filedropped      - intented to run as kiosk app
    -- SKIPPED directorydropped - intented to run as kiosk app
    -- SKIPPED lowmemory
    -- SKIPPED displayrotated   - target device has laptop form factor

    Controller.set_love_update()
  end,

  --- @param C ConsoleController
  setup_callback_handlers = function(C)
    local clear_user_input = function()
      love.state.user_input = nil
    end

    --- @diagnostic disable-next-line: undefined-field
    local handlers = love.handlers

    handlers.keypressed = function(k)
      -- Ensure the user can get back to the console
      if Key.ctrl() and Key.shift() then
        if k == "q" then
          C:quit_project()
        end
      end

      local user_input = get_user_input()
      if user_input then
        user_input.C:keypressed(k)
      else
        if love.keypressed then return love.keypressed(k) end
      end
    end

    handlers.textinput = function(t)
      local user_input = get_user_input()
      if user_input then
        user_input.C:textinput(t)
      else
        if love.textinput then return love.textinput(t) end
      end
    end

    handlers.keyreleased = function(k)
      local user_input = get_user_input()
      if user_input then
        user_input.C:keyreleased(k)
      else
        if love.keyreleased then return love.keyreleased(k) end
      end
    end

    handlers.mousepressed = function(x, y, btn)
      local user_input = get_user_input()
      if user_input then
        user_input.C:mousepressed(x, y, btn)
      else
        if love.mousepressed then return love.mousepressed(x, y, btn) end
      end
    end

    handlers.mousereleased = function(x, y, btn)
      local user_input = get_user_input()
      if user_input then
        user_input.C:mousereleased(x, y, btn)
      else
        if love.mousereleased then return love.mousereleased(x, y, btn) end
      end
    end

    handlers.mousemoved = function(x, y, dx, dy)
      local user_input = get_user_input()
      if user_input then
        user_input.C:mousemoved(x, y, dx, dy)
      else
        if love.mousemoved then return love.mousemoved(x, y, dx, dy) end
      end
    end

    handlers.userinput = function(input)
      local user_input = get_user_input()
      if user_input then
        clear_user_input()
      end
    end

    --- @diagnostic disable-next-line: undefined-field
    table.protect(love.handlers)
  end
}
