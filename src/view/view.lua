--- @type love.Image?
local canvas_snapshot = nil

View = {
  prev_draw = nil,
  main_draw = nil,
  --- @param C ConsoleController
  --- @param CV ConsoleView
  draw = function(C, CV)
    G.reset()
    G.push('all')
    local terminal = C:get_terminal()
    local canvas = C:get_canvas()
    local input = C.input:get_input()
    CV:draw(terminal, canvas, input, canvas_snapshot)
    G.pop()
  end,

  snap_canvas = function()
    -- G.captureScreenshot(os.time() .. ".png")
    if canvas_snapshot then
      View.clear_snapshot()
      collectgarbage()
    end
    G.captureScreenshot(function(img)
      canvas_snapshot = G.newImage(img)
    end)
  end,

  clear_snapshot = function()
    canvas_snapshot = nil
  end,
}
