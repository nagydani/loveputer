local width, height = G.getDimensions()
local midx = width / 2
local midy = height / 2
local incr = 5

local tx, ty = midx, midy
local r = {}

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

local function drawHelp()
  G.setColor(Color[Color.white])
  G.print("Press [I] to open console", 20, 20)
  G.print("Enter 'forward', 'back', 'left', or 'right' to move the turtle!", 20, 40)
end

local function eval()
  local input = r[1]
  if input == 'forward' or input == 'f' then
    ty = ty - incr
  end
  if input == 'back' or input == 'b' then
    ty = ty + incr
  end
  if input == 'left' or input == 'l' then
    tx = tx - (2 * incr)
  end
  if input == 'right' or input == 'r' then
    tx = tx + (2 * incr)
  end
end

function love.draw()
  drawHelp()
  drawTurtle(tx, ty)
end

function love.keypressed(key)
  if key == 'r' then
    tx, ty = midx, midy
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
