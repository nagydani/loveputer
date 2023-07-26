local G = love.graphics

Statusline = {}

function Statusline:new(cfg)
  local s = {
    cfg = cfg,
  }
  setmetatable(s, self)
  self.__index = self

  return s
end

function Statusline:draw(status, nLines, time)
  local cf = self.cfg
  local b = cf.border
  local h = cf.height
  local w = cf.width
  local fh = cf.fh
  local colors = cf.colors

  G.push('all')
  G.setColor(colors.border)
  local sy = h - b - (1 + nLines) * fh
  local start_box = { x = 0, y = sy }
  local start_text = {
    x = start_box.x + fh,
    y = start_box.y,
  }
  local endTextX = start_box.x + w - fh
  local midX = (start_box.x + w) / 2
  G.rectangle("fill", start_box.x, start_box.y, w, fh)

  if not status then return end
  G.setColor(colors.statusline.fg)
  if status.input_type then
    G.print(status.input_type, start_text.x, start_text.y)
  end
  if love.DEBUG then
    G.setColor(colors.debug)
    if love.state.testing then
      G.print('testing', midX - (7 * cf.fw + cf.border), start_text.y)
    end
    G.print(time, midX, start_text.y)
    G.setColor(colors.statusline.fg)
  end
  if status.cursor then
    local c = status.cursor
    local pos_l = 'L' .. c.l
    local pos_c = ':' .. c.c
    local lw = G.getFont():getWidth(pos_l)
    local cw = G.getFont():getWidth(pos_c)
    local sx = endTextX - (lw + cw)
    if c.l == status.n_lines then
      G.setColor(colors.statusline.indicator)
    end
    G.print(pos_l, sx, start_text.y)
    G.setColor(colors.statusline.fg)
    G.print(pos_c, sx + lw, start_text.y)
  end
  G.pop()
end
