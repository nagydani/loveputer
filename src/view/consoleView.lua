local _ = require("view/color")
local _ = require("view/titleView")
local _ = require("view/canvasView")
local _ = require("view/inputView")

local G = love.graphics

ConsoleView = {}

function ConsoleView:new(m, cfg)
  local conf = {
    fontSize = 18,
    colors = {
      bg = Color[Color.white],
      border = Color[Color.black + Color.bright],
      fg = Color[Color.blue + Color.bright],
      statFg = Color[Color.white + Color.bright],
    }
  }
  for k, v in pairs(cfg) do
    conf[k] = v
  end

  local FAC = 1
  if _G.hiDPI then FAC = 2 end
  G.scale(FAC, FAC)

  local fontDir = "assets/fonts/"
  conf.font_main = love.graphics.newFont(
    fontDir .. "ubuntu_mono_bold_nerd.ttf", cfg.fontSize * FAC)
  conf.font_title = love.graphics.newFont(
    fontDir .. "PressStart2P-Regular.ttf", cfg.fontSize * FAC)

  G.setFont(conf.font_main)

  local BORDER = 4 * FAC
  local FH = conf.font_main:getHeight()
  conf.fac = FAC
  conf.border = BORDER
  conf.fh = FH
  conf.width = G.getWidth()
  conf.height = G.getHeight()

  local view = {
    title = TitleView,
    canvas = CanvasView:new(conf),
    input = InputView:new(conf),
    model = m,
  }
  view.cfg = conf
  view.getDrawableHeight = function(h)
    return
        h - BORDER -- top border
        - FH       -- separator
        - FH       -- input line
        - BORDER   -- bottom border
  end

  setmetatable(view, self)
  self.__index = self

  return view
end

function ConsoleView:resize(wi, hi)
  local w = wi / self.cfg.fac
  local h = hi / self.cfg.fac

  self.canvasDrawableHeight = self.getDrawableHeight(h)

  local inputBox = {
    x = self.cfg.border,
    y = self.cfg.border + self.canvasDrawableHeight + 2 * self.cfg.border,
    w = w - 2 * self.cfg.border,
    h = self.cfg.fh,
  }

  love.keyboard.setTextInput(true,
    inputBox.x, inputBox.y, inputBox.w, inputBox.h)
end

-- function ConsoleView:draw(x, y, w, h)
function ConsoleView:draw()
  local b = self.cfg.border

  G.scale(self.fac, self.fac)

  local w = self.cfg.width
  local h = self.cfg.height
  local x, y = 0, 0

  if not self.canvasDrawableHeight then
    self.canvasDrawableHeight = self.getDrawableHeight(h)
  end

  local linesN = math.floor(self.canvasDrawableHeight / self.cfg.fh)
  self.cfg.linesN = linesN

  local background = {
    draw = function()
      G.setColor(self.cfg.colors.border)
      G.rectangle("fill", 0, 0, w, h)
      G.setColor(self.cfg.colors.bg)
      G.rectangle("fill", b, b, w - 2 * b, h - 2 * b)
    end,
  }

  background.draw()
  self.canvas:draw(self.model.result)
  self.input:draw(self.model.entered)
  -- self.title.draw('LÖVEputer', x, h / 2, w, self.font_title)
end
