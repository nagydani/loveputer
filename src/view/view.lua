View = {
  draw = function()
    G.push('all')
    local terminal = C:get_terminal()
    local input = C.input:get_input()
    CV:draw(terminal, input)
    G.pop()
  end,
  set_love_draw = function()
    --- @diagnostic disable-next-line: duplicate-set-field
    function love.draw()
      View.draw()
    end
  end,
}
