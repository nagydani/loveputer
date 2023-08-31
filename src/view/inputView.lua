local G = love.graphics

require("view.statusline")
require("util.debug")

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

  local function wrap_text(text)
    local display = {}
    local cursor_wrap = {}
    local breaks = 0
    for i, l in ipairs(text) do
      local n = math.floor(string.ulen(l) / drawableChars)
      -- remember how many apparent lines will be overall
      cursor_wrap[i] = n + 1
      breaks = breaks + n
      local lines = string.wrap_at(l, drawableChars)
      for _, tl in ipairs(lines) do
        table.insert(display, tl)
      end
    end
    return {
      display = display,
      cursor_wrap = cursor_wrap,
      breaks = breaks
    }
  end

  local isError = string.is_non_empty_string(input.error)
  local highlight = input.highlight
  local text = (function()
    if isError then
      return string.wrap_at(input.error, drawableChars - 1)
    else
      return input.text
    end
  end)()
  local inLines = #text
  local apparentLines = inLines
  local inHeight = inLines * fh
  local y = h - b - inHeight

  local apparentHeight = inHeight
  local wt = wrap_text(text)
  local display = wt.display
  local cursor_wrap = wt.cursor_wrap
  local breaks = wt.breaks
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

  --- Write a line of text to output
  ---@param l number
  ---@param str string
  local write_line = function(l, str)
    local dy = y - (-l + 1 + breaks) * fh
    G.print(str, b, dy)
  end
  --- Write a token to output
  ---@param l number
  ---@param c number
  ---@param token string
  ---@param color table
  local write_token = function(l, c, token, color)
    local dy = y - (-l + 1 + breaks) * fh
    local dx = b + (c - 1) * fw
    G.push('all')
    G.setColor(color)
    G.print(token, dx, dy)
    G.pop()
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
  if highlight and not isError then
    local perr = highlight.parse_err
    local el, ec
    if perr then
      el = perr.l
      ec = perr.c
    end
    for l, s in ipairs(display) do
      for i = 1, string.ulen(s) do
        local char = string.usub(s, i, i)
        local row = highlight.hl[l] or {}
        local ttype = row[i]
        local color
        if perr and l > el or
            (l == el and i > ec) then
          color = colors.error
        else
          color = colors.syntax[ttype] or colors.fg
        end
        write_token(l, i, char, color)
      end
    end
  else
    for l, str in ipairs(display) do
      write_line(l, str)
    end
  end
  G.pop()
end
