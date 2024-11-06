width, height = G.getDimensions()
midx = width / 2
midy = height / 2
incr = 10

tx, ty = midx, midy
debug = false
debugColor = Color.yellow

bg_color = Color.black

local r = {}

function drawBackground(color)
  local c = bg_color
  local not_green = color ~= Color.green
      and color ~= Color.green + Color.bright
  local color_valid = Color.valid(color) and not_green
  if color_valid then c = color end

  G.setColor(Color[c])
  G.rectangle('fill', 0, 0, width, height)
end

local function drawFrontLegs(x_r, y_r, leg_r)
  G.setColor(Color[Color.green + Color.bright])
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
end
local function drawHindLegs(x_r, y_r, leg_r)
  G.setColor(Color[Color.green + Color.bright])
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
end
local function drawBody(x_r, y_r, head_r)
  -- body
  G.setColor(Color[Color.green])
  G.ellipse("fill", 0, 0, x_r, y_r, 100)
  -- head
  G.circle("fill", 0, 0 - y_r - head_r + 5, head_r, 100)
end
function drawTurtle(x, y)
  local head_r = 8
  local leg_r = 5
  local x_r = 15
  local y_r = 20
  G.push('all')

  G.translate(x, y)
  drawFrontLegs(x_r, y_r, leg_r)
  drawHindLegs(x_r, y_r, leg_r)
  drawBody(x_r, y_r, head_r)
  G.pop()
end

local function drawHelp()
  G.setColor(Color[Color.white])
  G.print("Press [I] to open console", 20, 20)
  G.print("Enter 'forward', 'back', 'left', or 'right' to move the turtle!", 20, 40)
end

local function drawDebuginfo()
  G.setColor(Color[debugColor])
  local dt = string.format("Turtle position: (%d, %d)", tx, ty)
  G.print(dt, width - 200, 20)
end

function move_forward(d)
  ty = ty - (d or incr)
end

function move_back(d)
  ty = ty + (d or incr)
end

function move_left(d)
  tx = tx - (d or (2 * incr))
end

function move_right(d)
  tx = tx + (d or (2 * incr))
end

function pause() stop('user stop') end

actions = {
  forward = move_forward,
  fd      = move_forward,
  back    = move_back,
  b       = move_back,
  left    = move_left,
  l       = move_left,
  right   = move_right,
  r       = move_right,
  stop    = pause,
  pause   = pause,
}

function eval()
  local input = r[1]
  local f = actions[input]

  if f then f() end
end

function love.draw()
  drawBackground()
  drawHelp()
  drawTurtle(tx, ty)
  if debug then drawDebuginfo() end
end

function love.keypressed(key)
  if love.keyboard.isDown("lshift", "rshift") then
    if key == 'r' then
      tx, ty = midx, midy
    end
  end
  if key == 'space' then
    debug = not debug
  end
  if key == 'pause' then
    stop()
  end
end

function love.keyreleased(key)
  if key == 'i' then
    input_text(r)
  end
  if key == 'return' then
    eval()
  end

  if love.keyboard.isDown("lctrl", "rctrl") then
    if key == "escape" then
      love.event.quit()
    end
  end
end

local t = 0
function love.update(dt)
  t = t + dt
  if ty > midy then
    debugColor = Color.red
  end
end
