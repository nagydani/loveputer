local G = love.graphics

--- @class TerminalView
TerminalView = {}

--- @param terminal table
--- @param overlay boolean?
local function terminal_draw(terminal, overlay)
  local char_width, char_height =
      terminal.char_width, terminal.char_height
  if terminal.dirty then
    love.graphics.push('all')
    love.graphics.origin()

    love.graphics.setCanvas(terminal.canvas)
    -- love.graphics.clear(terminal.clear_color)
    love.graphics.setFont(terminal.font)
    local font_height = terminal.font:getHeight()
    for y, row in ipairs(terminal.buffer) do
      for x, char in ipairs(row) do
        local state = terminal.state_buffer[y][x]
        if state.dirty then
          if overlay then
            -- this clears everything permanently, wtf
            -- love.graphics.clear(terminal.clear_color_alpha)
            -- Log.once('overlay clear')
          end
          local left, top =
              (x - 1) * char_width,
              (y - 1) * char_height
          local bg, fg = (function()
            local back, fore
            if state.reversed then
              back, fore = state.color, state.backcolor
            else
              back, fore = state.backcolor, state.color
            end

            if overlay then
              back = Color.with_alpha(back, 0)
              fore = Color.with_alpha(fore, 0.6)
            end
            return back, fore
          end)()


          -- Character background
          if overlay then
            -- love.graphics.setColor(unpack(terminal.clear_color_alpha))
            -- love.graphics.rectangle("fill",
            --     left, top + (font_height - char_height),
            --     terminal.char_width, terminal.char_height)
          else
            love.graphics.setColor(unpack(bg))
            love.graphics.rectangle("fill",
              left, top + (font_height - char_height),
              terminal.char_width, terminal.char_height)
          end

          local bm, am = love.graphics.getBlendMode()
          G.setBlendMode('alpha', "alphamultiply")
          -- Character
          love.graphics.setColor(unpack(fg))
          love.graphics.print(char, left, top)
          Log.once('draw char')
          -- if x == 1 and y == 1 and overlay then
          if overlay then
            Log.once('fg', unpack(fg))
            Log.once('act fg', love.graphics.getColor())
            Log.once('bg', love.graphics.getBackgroundColor())
          end
          G.setBlendMode(bm, am)

          state.dirty = false
        end
      end
    end
    terminal.dirty = false
    love.graphics.pop()
  end

  if terminal.show_cursor then
    love.graphics.setFont(terminal.font)
    if love.timer.getTime() % 1 > 0.5 then
      love.graphics.print("_",
        (terminal.cursor_x - 1) * char_width,
        (terminal.cursor_y - 1) * char_height)
    end
  end
end

--- @param terminal table
function TerminalView.draw(terminal, snapshot)
  G.setCanvas()
  G.push('all')

  if snapshot then
    -- G.setBlendMode('multiply', "premultiplied")
    -- G.setBlendMode('screen', "premultiplied")
    -- terminal:draw(true)
    terminal_draw(terminal, true)
  else
    -- terminal:draw()
    terminal_draw(terminal)
  end
  G.draw(terminal.canvas)
  G.setBlendMode('alpha') -- default
  G.pop()
end
