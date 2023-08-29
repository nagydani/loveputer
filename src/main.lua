require("model/consoleModel")
local redirect_to = require("model/ioRedirect")
require("view/consoleView")
require("controller/consoleController")
local colors = require("conf/colors")

require("util/debug")

local G = love.graphics
local V

function love.load(args)
  local testrun = false
  local sizedebug = false
  for _, a in ipairs(args) do
    if a == '--test' then testrun = true end
    if a == '--size' then sizedebug = true end
  end

  local FAC = 1
  if love.hiDPI then FAC = 2 end
  local font_size = 32.4 * FAC
  local border = 0 * FAC

  local font_dir = "assets/fonts/"
  local font_main = love.graphics.newFont(
    font_dir .. "ubuntu_mono_bold_nerd.ttf", font_size)
  local font_title = love.graphics.newFont(
    font_dir .. "PressStart2P-Regular.ttf", font_size)
  local fh = font_main:getHeight()
  -- we use a monospace font, so the width should be the same for any input
  local fw = font_main:getWidth('█')
  local w = G.getWidth() - 2 * border
  local h = love.fixHeight
  local debugheight = 6
  local debugwidth = math.floor(debugheight * (80 / 25))
  local drawableWidth = w - 2 * border
  if sizedebug then
    drawableWidth = debugwidth * fw
  end

  love.keyboard.setTextInput(true)
  love.keyboard.setKeyRepeat(true)
  if love.system.getOS() == 'Android' then
    love.isAndroid = true
    love.window.setMode(w, h, {
      fullscreen = true,
      fullscreentype = "exclusive",
    })
  end

  -- properties
  local baseconf = {
    font_main = font_main,
    border = border,
    fh = fh,
    fw = fw,
    fac = FAC,
    w = w,
    h = h,
    get_drawable_height = function()
      local d = h - border -- top border
          - border         -- statusline border
          - fh             -- statusline
          - border         -- statusline bottom border
          - fh             -- input line
          - border         -- bottom border
      return math.floor(d / fh) * fh
    end,
    colors = colors,

    debugheight = debugheight,
    debugwidth = debugwidth,
    drawableWidth = drawableWidth,
    drawableChars = math.floor(drawableWidth / fw),
    testrun = testrun,
    sizedebug = sizedebug,
  }

  love.state = {
    testing = false
  }
  love.window.aspect = G.getWidth() / G.getHeight()

  M = Console:new(baseconf)
  C = ConsoleController:new(M)
  V = ConsoleView:new(baseconf, C)

  redirect_to(M)

  if testrun then
    C:autotest()
  end
end

function love.textinput(t)
  C:textinput(t)
end

function love.keypressed(k)
  C:keypressed(k)
end

function love.keyreleased(k)
  local ctrl = love.keyboard.isDown("lctrl", "rctrl")
  -- Ctrl held
  if ctrl then
    if k == "escape" then
      love.event.quit()
    end
  end
end

function love.update(dt)
  C:pass_time(dt)
end

function love.draw()
  local terminal = C:get_terminal()
  local input = C:get_input()
  V:draw(terminal, input)
end
