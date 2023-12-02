local times = 2

local G = love.graphics

local x0 = 0
local xe = G.getWidth()
local y0 = 0
local ye = love.fixHeight

local xh = xe / 2
local yh = ye / 2

G.setColor(1, 1, 1, .5)
G.setLineWidth(1)
G.line(xh, y0, xh, ye)
G.line(x0, yh, xe, yh)

G.setColor(1, 0, 0)
G.setPointSize(2)
for x = 0, xe do
  local amp = 100
  local v = 2 * math.pi * (x - xh) / xe
  local y = yh + math.sin(v * times) * amp
  G.points(x, y)
end
