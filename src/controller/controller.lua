Controller = {
  set_love_keypressed = function()
    (function()
      function love.keypressed(k)
        C:keypressed(k)
      end
    end)()
  end,

  set_default_handlers = function()
    Controller.set_love_keypressed()
  end
}
