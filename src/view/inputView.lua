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

  local colors = self.cfg.view.colors
  local b = self.cfg.view.border
  local fh = self.cfg.view.fh
  local fw = self.cfg.view.fw
  local h = self.cfg.view.h
  local drawableWidth = self.cfg.drawableWidth
  local drawableChars = self.cfg.drawableChars

  local isError = string.is_non_empty_string_array(input.wrapped_error)
  local highlight = input.highlight
  local text = (function()
    if isError then
      return input.wrapped_error
    else
      return input.text
    end
  end)()
  local inLines = #text
  local apparentLines = inLines
  local inHeight = inLines * fh
  local y = h - b - inHeight

  local apparentHeight = inHeight
  local display = (function()
    if isError then
      return input.wrapped_error
    else
      return input.wrapped_text
    end
  end)()
  local wt_info = input.wt_info
  local cursor_wrap = wt_info.cursor_wrap
  local wrap_reverse = wt_info.wrap_reverse
  local breaks = wt_info.breaks
  apparentHeight = apparentHeight + breaks
  apparentLines = apparentLines + breaks

  local start_y = h - b - apparentLines * fh
  local function drawCursor()
    local cursorInfo = self.controller.input:get_cursor_info()
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
      yh = yh + (cursor_wrap[i] or 0)
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
    G.setColor(colors.input.cursor)
    G.print('|', b + (x_offset - 1.5) * fw, ch)
    G.pop()
  end

  local drawBackground = function()
    if isError then
      G.setColor(colors.input.error_bg)
    else
      G.setColor(colors.input.bg)
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
  local write_token = function(l, c, token, color, selected)
    local dy = y - (-l + 1 + breaks) * fh
    local dx = b + (c - 1) * fw
    G.push('all')
    if selected then
      G.setColor(color)
      G.print('█', dx, dy)
      G.setColor(colors.input.bg)
    else
      G.setColor(color)
    end
    G.print(token, dx, dy)
    G.pop()
  end

  -- draw
  G.push('all')
  G.setFont(self.cfg.view.font)
  G.setBackgroundColor(colors.input.bg)
  G.setColor(colors.input.fg)
  self.statusline:draw(status, apparentLines, time)
  drawBackground()
  if isError then
    G.setColor(colors.input.error)
  else
    G.setColor(colors.input.fg)
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
        local hl_li = wrap_reverse[l]
        local hl_ci = (function()
          if cursor_wrap[hl_li] > 1 then
            local offset = l - hl_li
            return i + drawableChars * offset
          else
            return i
          end
        end)()
        local row = highlight.hl[hl_li] or {}
        local ttype = row[hl_ci]
        local color
        if perr and l > el or
            (l == el and (i > ec or ec == 1)) then
          color = colors.input.error
        else
          color = colors.input.syntax[ttype] or colors.input.fg
        end
        local selected = (function()
          local sel = input.selection
          local startl = sel.start and sel.start.l
          local endl = sel.fin and sel.fin.l
          if startl then
            local startc = sel.start.c
            local endc = sel.fin.c
            if startc and endc then
              if startl == endl then
                local sc = math.min(sel.start.c, sel.fin.c)
                local endi = math.max(sel.start.c, sel.fin.c)
                return l == startl and i >= sc and i < endi
              else
                return
                    (l == startl and i >= sel.start.c) or
                    (l > startl and l < endl) or
                    (l == endl and i < sel.fin.c)
              end
            end
          end
        end)()
        write_token(l, i, char, color, selected)
      end
    end
  else
    for l, str in ipairs(display) do
      write_line(l, str)
    end
  end
  G.pop()
end
