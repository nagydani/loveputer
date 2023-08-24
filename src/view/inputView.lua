local G = love.graphics

require("view/statusline")

require("util/debug")

InputView = {}

function InputView:new(cfg, ctrl)
  local iv = {
    cfg = cfg,
    controller = ctrl,
    statusline = Statusline:new(cfg),
  }
  setmetatable(iv, self)
  self.__index = self

  return iv
end

function InputView:draw(input)
  local time = self.controller:get_timestamp()
  local status = self.controller:get_status()

  local colors = self.cfg.colors.input
  local b = self.cfg.border
  local fh = self.cfg.fh
  local fw = self.cfg.fw
  local h = self.cfg.h
  local drawableWidth = self.cfg.drawableWidth
  local drawableChars = self.cfg.drawableChars

  local isError = string.is_non_empty_string(input.err)
  local text = (function()
    if isError then
      return string.wrap_at(input.err, drawableChars - 1)
    else
      return input.text
    end
  end)()
  local inLines = #text
  local apparentLines = inLines
  local inHeight = inLines * fh
  local y = h - b - inHeight

  local display = {}
  local cursor_wrap = {}
  local apparentHeight = inHeight
  local app = 0
  local breaks = 0
  for i, l in ipairs(text) do
    local n = math.floor(string.ulen(l) / drawableChars)
    -- remember how many apparent lines will be overall
    cursor_wrap[i] = n + 1
    breaks = breaks + n
    local lines = string.wrap_at(l, drawableChars)
    app = app + #lines
    for _, tl in ipairs(lines) do
      table.insert(display, tl)
    end
  end
  apparentHeight = apparentHeight + breaks
  apparentLines = apparentLines + breaks

  local start_y = h - b - apparentLines * fh
  local function drawCursor()
    local cursorInfo = self.controller:get_cursor_info()
    local cl, cc = cursorInfo.cursor.l, cursorInfo.cursor.c
    local x_offset = (function()
      if cc > drawableChars then
        return math.fmod(cc, drawableChars)
      else
        return cc
      end
    end)()
    local y_offset = math.floor((cc - 1) / drawableChars)
    local yh = 0
    local n = cursor_wrap[cl] or 0
    -- how many apparent lines we have so far?
    for i = 1, cl do
      yh = yh + cursor_wrap[i]
    end
    local ch =
    -- top of the box
        start_y +
        -- full height of input line
        yh * fh
        -- adjust in-line: from all lines, move back
        -- the number of line wraps
        - (n - y_offset) * fh
    G.push('all')
    G.setColor(colors.cursor)
    G.print('|', b + (x_offset - 1.5) * fw, ch)
    G.pop()
  end

  local drawBackground = function()
    if isError then
      G.setColor(colors.error_bg)
    else
      G.setColor(colors.bg)
    end
    G.rectangle("fill",
      b,
      start_y,
      drawableWidth,
      apparentHeight * fh)
  end
  local write_line = function(i, l)
    local dy = y - (-i + 1 + breaks) * fh
    G.print(l, b, dy)
  end

  -- draw
  G.push('all')
  G.setFont(self.cfg.font_main)
  self.statusline:draw(status, apparentLines, time)
  drawBackground()
  if isError then
    G.setColor(colors.error)
  else
    G.setColor(colors.fg)
    if love.timer.getTime() % 1 > 0.5 then
      drawCursor()
    end
  end
  for i, l in ipairs(display) do
    write_line(i, l)
  end
  G.pop()
end
