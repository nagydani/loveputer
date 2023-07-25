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
  local text_line = "Per character-colors !"
  for i, c in utf8.codes(text_line) do
    local ch = utf8.char(c)
    local index_fg, index_bg = (i - 1) % 8, (i + 5) % 8
    term:set_cursor_color(Terminal.schemes.basic[index_fg])
    term:set_cursor_backcolor(Terminal.schemes.basic[index_bg])
    term:print(ch)
  end


  -- reset
  term:set_cursor_color(unpack(prev_fg_color))
  term:set_cursor_backcolor(unpack(prev_bg_color))
end
