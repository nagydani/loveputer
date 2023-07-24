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

function Statusline:draw(status, inLines, time)
  local cf = self.cfg
  local b = cf.border
  local h = cf.height
  local w = cf.width
  local fh = cf.fh
  local colors = cf.colors

  G.push('all')
  G.setColor(colors.border)
  local sy = h - b - (1 + inLines) * fh
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
    G.print(time, midX, start_text.y)
    G.setColor(colors.statusline.fg)
  end
  if status.cursor then
    local c = status.cursor
    local pos = 'L' .. c.l .. ':' .. c.c
    local sx = endTextX - G.getFont():getWidth(pos)
    G.print(pos, sx, start_text.y)
  end
  G.pop()
end
