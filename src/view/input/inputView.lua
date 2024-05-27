local G = love.graphics

require("view.input.statusline")
require("util.debug")
require("util.view")

--- @class InputView
--- @field cfg ViewConfig
--- @field controller InputController
--- @field statusline table
--- @field oneshot boolean
--- @field draw function
InputView = {}
InputView.__index = InputView

setmetatable(EditorController, {
  __call = function(cls, ...)
    return cls.new(...)
  end,
})

--- @param cfg ViewConfig
--- @param ctrl InputController
function InputView.new(cfg, ctrl)
  local self = setmetatable({
    cfg = cfg,
    controller = ctrl,
    statusline = Statusline:new(cfg),
    oneshot = ctrl.model.oneshot,
  }
  , InputView)

  return self
end

--- @param input InputDTO
--- @param time number
function InputView:draw(input, time)
  local status = self.controller:get_status()
  local cf_colors = self.cfg.colors
  local colors = (function()
    if love.state.app_state == 'inspect' then
      return cf_colors.input.inspect
    elseif love.state.app_state == 'running' then
      return cf_colors.input.user
    else
      return cf_colors.input.console
    end
  end)()
  local b = self.cfg.border
  local fh = self.cfg.fh
  local fw = self.cfg.fw
  local h = self.cfg.h
  local drawableWidth = self.cfg.drawableWidth
  local drawableChars = self.cfg.drawableChars
  -- drawtest hack
  if drawableWidth < love.fixWidth / 3 then
    drawableChars = drawableChars * 2
  end

  local highlight = input.highlight
  local text = input.text
  local inLines = #text
  local apparentLines = inLines
  local inHeight = inLines * fh
  local y = h - b - inHeight

  local apparentHeight = inHeight
  local wt = input.wrapped_text
  local display = wt.text
  local cursor_wrap = wt.cursor_wrap
  local wrap_reverse = wt.wrap_reverse
  local breaks = wt.n_breaks
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
    G.setColor(cf_colors.input.cursor)
    G.print('|', b + (x_offset - 1.5) * fw, ch)
    G.pop()
  end

  local drawBackground = function()
    G.setColor(colors.bg)
    G.rectangle("fill",
      b,
      start_y,
      drawableWidth,
      apparentHeight * fh)
  end

  --- Write a token to output
  --- @param l number
  --- @param c number
  --- @param token string
  --- @param color table
  local write_token = function(l, c, token, color, selected)
    local dy = y - (-l + 1 + breaks) * fh
    local dx = b + (c - 1) * fw
    G.push('all')
    if selected then
      G.setColor(color)
      G.print('█', dx, dy)
      G.setColor(colors.bg)
    else
      G.setColor(color)
    end
    G.print(token, dx, dy)
    G.pop()
  end

  -- draw
  G.push('all')
  G.scale(self.cfg.FAC, self.cfg.FAC)
  G.setFont(self.cfg.font)
  G.setBackgroundColor(colors.bg)
  G.setColor(colors.fg)
  self.statusline:draw(status, apparentLines, time, self.oneshot)
  drawBackground()

  G.setColor(colors.fg)
  if love.timer.getTime() % 1 > 0.5 then
    drawCursor()
  end
  if highlight then
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
          color = cf_colors.input.error
        else
          color = cf_colors.input.syntax[ttype] or colors.fg
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
      ViewUtils.write_line(l, str, { y = y, breaks = breaks }, self.cfg)
    end
  end
  G.pop()
end
