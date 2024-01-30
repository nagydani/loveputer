require("model.model")
local redirect_to = require("model.io.redirect")
require("view.consoleView")
require("controller.controller")
require("controller.consoleController")
require("view.view")
local colors = require("conf.colors")

require("util.key")
require("util.debug")

G = love.graphics

--- Find removable and user-writable storage
--- Assumptions are made, which are might be to the target platform/device
---@return boolean success
---@return string? path
local android_storage_find = function()
  -- Yes, I know. We are working with the limitations of Android here.
  local quadhex = string.times('[0-9A-F]', 4)
  local uuid_regex = quadhex .. '-' .. quadhex
  local regex = '/dev/fuse /storage/' .. uuid_regex
  local handle = io.popen(string.format("grep /proc/mounts -e '%s'", regex))
  if not handle then
    return false
  end
  local result = handle:read("*a")
  handle:close()
  local lines = string.lines(result)
  if not string.is_non_empty_string_array(lines) then
    return false
  end
  local tok = string.split(lines[1], ' ')
  if string.is_non_empty_string_array(tok) then
    return true, tok[2]
  end
  return false
end

function love.load(args)
  --- CLI arguments
  local testrun = false
  local sizedebug = false
  for _, a in ipairs(args) do
    if a == '--test' then testrun = true end
    if a == '--size' then sizedebug = true end
  end

  --- Display
  local FAC = 1
  if love.hiDPI then FAC = 2 end
  local font_size = 32.4 * FAC
  local border = 0 * FAC

  local font_dir = "assets/fonts/"
  local font_main = love.graphics.newFont(
    font_dir .. "ubuntu_mono_bold_nerd.ttf", font_size)
  local lh = 1.0468
  font_main:setLineHeight(lh)
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

  local id = love.filesystem.getIdentity()
  local storage_path = ''
  local project_path, has_removable
  --- Android
  love.keyboard.setTextInput(true)
  love.keyboard.setKeyRepeat(true)
  if love.system.getOS() == 'Android' then
    love.isAndroid = true
    love.window.setMode(w, h, {
      fullscreen = true,
      fullscreentype = "exclusive",
    })
    local ok, sd_path = android_storage_find()
    if not ok then
      print('WARN: SD card not found')
      has_removable = false
      sd_path = '/storage/emulated/0'
    end
    has_removable = true
    storage_path = string.format("%s/Documents/%s", sd_path, id)
    print('INFO: Project path: ' .. storage_path)
  end

  -- storage
  if love.system.getOS() ~= 'Android' then
    -- TODO: linux assumed, check other platforms, especially love.js
    local home = os.getenv('HOME')
    if home and string.is_non_empty_string(home) then
      storage_path = string.format("%s/Documents/%s", home, id)
    else
      storage_path = love.filesystem.getSaveDirectory()
    end
  end
  project_path = storage_path .. '/projects'

  --- @type PathInfo
  local paths = {
    storage_path = storage_path,
    project_path = project_path
  }
  for _, d in pairs(paths) do
    local ok, err = FS.mkdir(d)
    if not ok then Log(err) end
  end

  _G.nativefs = require("lib/nativefs")
  --- @type LoveState
  love.state = {
    testing = false,
    has_removable = has_removable,
    user_input = nil,
    app_state = 'ready'
  }
  love.paths = paths

  --- @class ViewConfig
  local viewconf = {
    font = font_main,
    border = border,
    fh = fh,
    fw = fw,
    lh = lh,
    fac = FAC,
    w = w,
    h = h,
    colors = colors,
  }
  --- @class Config
  local baseconf = {
    view = viewconf,

    debugheight = debugheight,
    debugwidth = debugwidth,
    drawableWidth = drawableWidth,
    drawableChars = math.floor(drawableWidth / fw),
    testrun = testrun,
    sizedebug = sizedebug,
  }
  --- MVC wiring
  local M = Model:new(baseconf)
  redirect_to(M)
  local C = ConsoleController.new(M)
  CV = ConsoleView:new(baseconf, C)
  C:set_view(CV)

  Controller.setup_callback_handlers(C)
  Controller.set_default_handlers(C)

  --- run autotest on startup if invoked
  if testrun then C:autotest() end
end

