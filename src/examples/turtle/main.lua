local width, height = love.graphics.getDimensions()
local midx = width / 2
local midy = height / 2

local x, y = midx, midy
local incr = 5

local function drawTurtle(x, y)
  local head_r = 8
  local leg_r = 5
  local x_r = 15
  local y_r = 20
  G.setColor(Color[Color.green + Color.bright])
  G.push('all')

  G.translate(x, y)

  -- front legs
  G.push('all')
  G.translate(-x_r, -y_r / 2 - leg_r)
  G.rotate(-math.pi / 4)
  G.ellipse("fill", 0, 0, leg_r, 10, 100)
  G.pop()
  G.push('all')
  G.translate(x_r, -y_r / 2 - leg_r)
  G.rotate(math.pi / 4)
  G.ellipse("fill", 0, 0, leg_r, 10, 100)
  G.pop()
  -- hind legs
  G.push('all')
  G.translate(-x_r, y_r / 2 + leg_r)
  G.rotate(math.pi / 4)
  G.ellipse("fill", 0, 0, leg_r, 10, 100)
  G.pop()
  G.push('all')
  G.translate(x_r, y_r / 2 + leg_r)
  G.rotate(-math.pi / 4)
  G.ellipse("fill", 0, 0, leg_r, 10, 100)
  G.pop()
  -- body
  G.setColor(Color[Color.green])
  G.ellipse("fill", 0, 0, x_r, y_r, 100)
  -- head
  G.circle("fill", 0, 0 - y_r - head_r + 5, head_r, 100)
  G.pop()
end

function love.draw()
  drawTurtle(x, y)
end
