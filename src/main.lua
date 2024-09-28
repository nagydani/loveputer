local redirect_to = require("model.io.redirect")
require("model.consoleModel")
require("controller.controller")
require("controller.consoleController")
require("view.view")
require("view.consoleView")

local colors = require("conf.colors")
local hostconf = prequire('host')

require("util.key")
require("util.debug")

require("lib/error_explorer")

G = love.graphics

--- Find removable and user-writable storage
--- Assumptions are made, which might be specific to the target platform/device
--- @return boolean success
--- @return string? path
local android_storage_find = function()
  local OS = require("util.os")
  -- Yes, I know. We are working with the limitations of Android here.
  local quadhex = string.times('[0-9A-F]', 4)
  local uuid_regex = quadhex .. '-' .. quadhex
  local regex = '/dev/fuse /storage/' .. uuid_regex
  local grep = string.format("grep /proc/mounts -e '%s'", regex)
  local _, result = OS.runcmd(grep)
  local lines = string.lines(result or '')
  if not string.is_non_empty_string_array(lines) then
    return false
  end
  local tok = string.split(lines[1], ' ')
  if string.is_non_empty_string_array(tok) then
    return true, tok[2]
  end
  return false
end

--- CLI arguments
--- @param args table
local argparse = function(args)
  local autotest = false
  local drawtest = false
  local sizedebug = false
  for _, a in ipairs(args) do
    if a == '--autotest' then autotest = true end
    if a == '--size' then sizedebug = true end
    if a == '--drawtest' then
      drawtest = true
      sizedebug = true
    end
  end
  return autotest, drawtest, sizedebug
end

--- Display
--- @return ViewConfig
local config_view = function(sizedebug)
  local FAC = 1
  if love.hiDPI then FAC = 2 end
  local font_size = 32.4 * FAC
  local border = 0 * FAC

  local font_dir = "assets/fonts/"
  local font_main = G.newFont(
    font_dir .. "ubuntu_mono_bold_nerd.ttf", font_size)
  local font_icon = G.newFont(
    font_dir .. "SFMonoNerdFontMono-Regular.otf", font_size)
  local lh = (function()
    if sizedebug then
      return 1
    else
      return 1.0468
    end
  end)()
  font_main:setLineHeight(lh)
  local fh = font_main:getHeight()
  -- we use a monospace font, so the width should be the same for any input
  local fw = font_main:getWidth('█') -- 16x32

  -- this should lead to 16 lines visible by default on the
  -- console and the editor
  local lines = 16
  local input_max = 14

  local font_labels = G.newFont(
    font_dir .. "PressStart2P-Regular.ttf", 12)

  local w = G.getWidth() - 2 * border
  local h = love.fixHeight
  local eh = h - 2 * fh
  local debugheight = math.floor(eh / (love.test_grid_y * fh))
  local debugwidth = math.floor(love.fixWidth / love.test_grid_x) / fw
  local drawableWidth = w - 2 * border
  if sizedebug then
    drawableWidth = debugwidth * fw
  end
  -- drawtest hack
  if drawableWidth < love.fixWidth / 3 then
    drawableWidth = drawableWidth * 2
  end

  local drawableChars = math.floor(drawableWidth / fw)
  if love.DEBUG then drawableChars = drawableChars - 3 end

  return {
    font = font_main,
    iconfont = font_icon,
    fh = fh,
    fw = fw,
    lh = lh,
    lines = lines,
    input_max = input_max,
    show_append_hl = false,

    labelfont = font_labels,
    lfh = font_labels:getHeight(),
    lfw = font_labels:getWidth('█'),

    border = border,
    FAC = FAC,
    w = w,
    h = h,
    colors = colors,

    debugheight = debugheight,
    debugwidth = debugwidth,
    drawableWidth = drawableWidth,
    drawableChars = drawableChars,
  }
end

--- Android sepcific settings
local setup_android = function(viewconf)
  love.keyboard.setTextInput(true)
  love.keyboard.setKeyRepeat(true)
  if love.system.getOS() == 'Android' then
    love.isAndroid = true
    love.window.setMode(viewconf.w, viewconf.h, {
      fullscreen = true,
      fullscreentype = "exclusive",
    })
  end
end

--- @return PathInfo
--- @return boolean
local setup_storage = function()
  local id = love.filesystem.getIdentity()
  local storage_path = ''
  local project_path, has_removable
  if love.system.getOS() ~= 'Android' then
    -- TODO: linux assumed, check other platforms, especially love.js
    local home = os.getenv('HOME')
    if home and string.is_non_empty_string(home) then
      storage_path = string.format("%s/Documents/%s", home, id)
    else
      storage_path = love.filesystem.getSaveDirectory()
    end
  else
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
  project_path = storage_path .. '/projects'
  local paths = {
    storage_path = storage_path,
    project_path = project_path
  }
  for _, d in pairs(paths) do
    local ok, err = FS.mkdir(d)
    if not ok then Log(err) end
  end
  return paths, has_removable
end

--- @param args table
---@diagnostic disable-next-line: duplicate-set-field
function love.load(args)
  local autotest, drawtest, sizedebug = argparse(args)

  local viewconf = config_view(sizedebug)

  setup_android(viewconf)

  local has_removable
  love.paths, has_removable = setup_storage()

  _G.nativefs = require("lib/nativefs")
  --- @type LoveState
  love.state = {
    testing = false,
    has_removable = has_removable,
    user_input = nil,
    app_state = 'ready'
  }
  if love.DEBUG then
    love.debug = {
      show_snapshot = true,
      show_terminal = true,
      show_canvas = true,
      show_input = true,
      once = 0
    }
  end

  local editorconf = {
    --- TODO
    mouse_enabled = false,
  }

  --- @class Config
  local baseconf = {
    view = viewconf,
    editor = editorconf,
    autotest = autotest,
    drawtest = drawtest,
    sizedebug = sizedebug,
  }

  if hostconf then
    hostconf.conf_app(viewconf)
  end

  --- MVC wiring
  local CM = ConsoleModel(baseconf)
  redirect_to(CM)
  local CC = ConsoleController(CM)
  local CV = ConsoleView(baseconf, CC)
  CC:set_view(CV)

  Controller.setup_callback_handlers(CC)
  Controller.set_default_handlers(CC, CV)

  --- run autotest on startup if invoked
  if autotest then CC:autotest() end
end
