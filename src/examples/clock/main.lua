width, height = G.getDimensions()
midx = width / 2
midy = height / 2

H = os.date('%H')
M = os.date('%M')
S = os.date('%S')
t = S + 60 * M + 60 * 60 * H
midnight = 24 * 60 * 60 * 60
s = 0

-- color = Color.cyan
-- bgcolor = Color.black
math.randomseed(os.time())
color = math.random(7)
bgcolor = math.random(7)
font = G.newFont(72)

function love.draw()
  G.setColor(Color[color + Color.bright])
  G.setBackgroundColor(Color[bgcolor])
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

function cycle(c)
  if c > 7 then return 1 end
  return c + 1
end

function love.keyreleased(k)
  if k == 'space' then
    if love.keyboard.isDown("lshift", "rshift") then
      bgcolor = cycle(bgcolor)
    else
      color = cycle(color)
    end
  end
  if k == 's' then
    stop('STOP THE CLOCKS!')
  end
end
