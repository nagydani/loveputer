local utf8 = require("utf8")

local Terminal = require "lib/terminal"

TerminalTest = {}

function TerminalTest:new(ctrl)
  setmetatable({}, self)
  self.__index = self

  return self
end

function TerminalTest:test(term)
  local w = term.width
  local h = term.height
  -- save previous state
  local prev_fg_color = term.cursor_color
  local prev_bg_color = term.cursor_backcolor

  local set_colors = function(fg, bg)
    local foreground = fg or prev_fg_color
    local background = bg or prev_bg_color
    term:set_cursor_color(unpack(foreground))
    term:set_cursor_backcolor(unpack(background))
  end
  -- test
  local setup = function()
    term:clear()
    term:move_to(2, 2)
  end
  local frame = function(x, y, w, h, style)
    local s = style or 'line'
    term:frame(s, x, y, w, h)
  end
  local color_frame = function(x, y, w, h, fg, bg, style)
    term:set_cursor_color(fg)
    term:set_cursor_backcolor(bg)
    frame(x, y, w, h, style)
  end

  local newline = function()
    term:print('\n')
  end
  local colors = function()
    local prev_fg = term.cursor_color
    local prev_bg = term.cursor_backcolor
    local text_line = "Per character-colors !"
    for i, c in utf8.codes(text_line) do
      local ch = utf8.char(c)
      local index_fg, index_bg = (i - 1) % 8, (i + 5) % 8
      term:set_cursor_color(Terminal.schemes.basic[index_fg])
      term:set_cursor_backcolor(Terminal.schemes.basic[index_bg])
      term:print(ch)
    end
    term:print('\n')
    term:set_cursor_color(unpack(prev_fg))
    term:set_cursor_backcolor(unpack(prev_bg))
  end
  local jump = function(x, y)
    term:move_to(x, y)
  end
  local wait = function(x, y)
    term:set_cursor_color(Color[Color.green])
    term:set_cursor_backcolor(Color[Color.black])
    love.state.testing = 'waiting'
    if not x and not y then
      term:print('Press any key to continue')
    else
      term:print(x, y, 'Press any key to continue')
    end
  end

  setup()
  frame(1, 1, w, h, 'thick')
  color_frame(10, 10, 10, 10,
    Color[Color.black],
    Color[Color.white + Color.bright])
  jump(40, 10)
  set_colors()
  term:print('Jump around!')
  jump(40, 11)
  term:reverse_cursor(true)
  term:print('Reverse colors!')
  term:reverse_cursor()
  jump(40, 12)
  color_frame(90, 10, 10, 10,
    Color[Color.red],
    Color[Color.yellow + Color.bright])
  color_frame(5, h - 5, w - 10, 3, Color[Color.cyan + Color.bright], Color[Color.yellow], 'block')
  colors()

  wait(2, h - 1)

  -- reset
  set_colors()
end

function TerminalTest:reset(term)
  term:move_to(1, 1)
  term:clear()
end
