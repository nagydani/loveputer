View = {
  prev_draw = nil,
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
  end,
}
