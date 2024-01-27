--- @type love.Image?
local canvas_snapshot = nil

View = {
  prev_draw = nil,
  main_draw = nil,
  --- @param C ConsoleController
  draw = function(C)
    G.push('all')
    local terminal = C:get_terminal()
    local input = C.input:get_input()
    CV:draw(terminal, input)
    G.pop()
  end,

  --- @param C ConsoleController
  set_love_draw = function(C)
    local function draw()
      View.draw(C)
    end
    love.draw = draw

    View.prev_draw = love.draw
    View.main_draw = love.draw
  end,

  snap_canvas = function()
    -- G.captureScreenshot(os.time() .. ".png")
    G.captureScreenshot(function(img)
      canvas_snapshot = G.newImage(img)
    end)
  end,

  clear_snapshot = function()
    canvas_snapshot = nil
  end,
}
