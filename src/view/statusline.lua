local G = love.graphics

Statusline = {}

function Statusline:new(cfg)
  local s = {
    cfg = cfg,
    status = Status:new(),
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
  G.setColor(colors.statFg)
  if self.status.inputType then
    G.print(self.status.inputType, startText.x, startText.y)
  end
  if self.status.cursor then
    local c = self.status.cursor
    local pos = 'L' .. c.l .. ':' .. c.c
    local sx = endTextX - G.getFont():getWidth(pos)
    G.print(pos, sx, startText.y)
  end
end

Status = {}
function Status:new()
  local s = {
    inputType = 'text',
    cursor = { c = 1, l = 1 }
  }
  setmetatable(s, self)
  self.__index = self

  return s
end
