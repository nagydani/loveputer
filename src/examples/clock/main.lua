width, height = G.getDimensions()
midx = width / 2
midy = height / 2

local m = 60
local h = m * m
midnight = 24 * m * h

local H, M, S, t
function setTime()
  H = os.date("%H")
  M = os.date("%M")
  S = os.date("%S")
  t = S + m * M + h * H
end
setTime()
s = 0

math.randomseed(os.time())
color = math.random(7)
bg_color = math.random(7)
font = G.newFont(72)

local function pad(i)
  return string.format('%02d', i)
end

function getTimestamp()
  local hours_f = pad(math.floor(s / h))
  local minutes_f = pad(math.fmod(math.floor(s / m), m))

  local hours = s >= h and hours_f or '00'
  local minutes = s >= m and minutes_f or '00'
  local seconds = pad(math.floor(math.fmod(s, m)))
  return string.format('%s:%s:%s', hours, minutes, seconds)
end

function love.draw()
  G.setColor(Color[color + Color.bright])
  G.setBackgroundColor(Color[bg_color])
  G.setFont(font)

  local text = getTimestamp()
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

function cycle(c)
  if c > 7 then return 1 end
  return c + 1
end

local function shift()
  return love.keyboard.isDown("lshift", "rshift")
end
local function color_cycle(k)
  if k == "space" then
    if shift() then
      bg_color = cycle(bg_color)
    else
      color = cycle(color)
    end
  end
end
function love.keyreleased(k)
  color_cycle(k)
  if k == "r" and shift() then
    setTime()
  end
  if k == "s" then
    stop("STOP THE CLOCKS!")
  end
end
