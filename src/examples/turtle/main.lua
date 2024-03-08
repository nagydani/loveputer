width, height = G.getDimensions()
midx = width / 2
midy = height / 2
incr = 5

tx, ty = midx, midy
debug = false
debugColor = Color.yellow

local r = {}

function drawTurtle(x, y)
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

local function drawHelp()
  G.setColor(Color[Color.white])
  G.print("Press [I] to open console", 20, 20)
  G.print("Enter 'forward', 'back', 'left', or 'right' to move the turtle!", 20, 40)
end

local function drawDebuginfo()
  G.setColor(Color[debugColor])
  local label = string.format("Turtle position: (%d, %d)", tx, ty)
  G.print(label, width - 200, 20)
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

local function eval()
  local input = r[1]
  if input == 'forward' or input == 'f' then
    move_forward()
  end
  if input == 'back' or input == 'b' then
    move_back()
  end
  if input == 'left' or input == 'l' then
    move_left()
  end
  if input == 'right' or input == 'r' then
    move_right()
  end
end

function love.draw()
  drawHelp()
  drawTurtle(tx, ty)
  if debug then drawDebuginfo() end
end

function love.keypressed(key)
  if key == 'r' then
    tx, ty = midx, midy
  end
  if key == 'space' then
    debug = not debug
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
    debug = true
    debugColor = Color.red
  end
  if tx < midx then
    stop('turtle in lower half')
  end
end
