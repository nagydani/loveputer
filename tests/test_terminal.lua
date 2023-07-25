local utf8 = require("utf8")

local Terminal = require "lib/terminal"

TerminalTest = {}

function TerminalTest:new(ctrl)
  setmetatable({}, self)
  self.__index = self

  return self
end

function TerminalTest:test(term)
  -- save previous state
  local prev_fg_color = term.cursor_color
  local prev_bg_color = term.cursor_backcolor

  -- test
  term:clear()
  term:move_to(1, 1)
  local text_line = "Per character-colors !"
  for i, c in utf8.codes(text_line) do
    local ch = utf8.char(c)
    local index_fg, index_bg = (i - 1) % 8, (i + 5) % 8
    term:set_cursor_color(Terminal.schemes.basic[index_fg])
    term:set_cursor_backcolor(Terminal.schemes.basic[index_bg])
    term:print(ch)
  end
  term:print('\n')
  term:set_cursor_color(Color[Color.green])
  term:set_cursor_backcolor(Color[Color.black])
  love.state.testing = 'waiting'
  term:print('Press any key to continue')


  -- reset
  term:set_cursor_color(unpack(prev_fg_color))
  term:set_cursor_backcolor(unpack(prev_bg_color))
end

function TerminalTest:reset(term)
  term:move_to(1, 1)
  term:clear()
end
