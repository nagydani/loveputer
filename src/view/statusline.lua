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

function Statusline:draw(status)
  local cf = self.cfg
  local b = cf.border
  local h = cf.height
  local w = cf.width
  local fh = cf.fh
  local colors = cf.colors

  G.setColor(colors.border)
  local startBox = { x = 0, y = h - b - 2 * fh - b }
  local startText = {
    x = startBox.x + fh,
    y = startBox.y,
  }
  local endTextX = startBox.x + w - fh
  G.rectangle("fill", startBox.x, startBox.y, w, fh)

  if not status then return end
  G.setColor(colors.statFg)
  if status.inputType then
    G.print(status.inputType, startText.x, startText.y)
  end
  if status.cursor then
    local c = status.cursor
    local pos = 'L' .. c.l .. ':' .. c.c
    local sx = endTextX - G.getFont():getWidth(pos)
    G.print(pos, sx, startText.y)
  end
end
