local width, height = G.getDimensions()
local midx = width / 2
local midy = height / 2

local t = 0
local noon = 12 * 60 * 60 * 60
local midnight = 24 * 60 * 60 * 60
local s = 0

local color = Color.cyan
local font = G.newFont(72)

function love.draw()
  G.setColor(Color[color + Color.bright])
  G.setBackgroundColor(Color[Color.black])
  G.setFont(font)
  local m = 60
  local h = m * m
  local hours = ''
  if s >= h then
    hours = string.format('%02d', math.floor(s / h))
  else
    hours = '00'
  end
  local minutes = ''
  if s >= m then
    minutes = string.format('%02d', math.fmod(math.floor(s / m), m))
  else
    minutes = '00'
  end
  local seconds = math.floor(math.fmod(s, m))
  local text = string.format('%s:%s:%02d', hours, minutes, seconds)
  local l = string.len(text)
  local off_x = l * font:getWidth(' ')
  local off_y = font:getHeight() / 2
  G.print(text, midx - off_x, midy - off_y, 0, 1, 1)
end

function love.update(dt)
  t = t + dt
  s = math.floor(t)
  if s > midnight then s = 0 end
end

function love.keyreleased(k)
  if k == 'space' then
    if color > 7 then
      color = 1
    else
      color = color + 1
    end
  end
end
