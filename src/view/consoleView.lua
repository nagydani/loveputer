require("view/color")
require("view/titleView")
require("view/canvasView")
require("view/inputView")

require("util/debug")

local G = love.graphics

ConsoleView = {}

function ConsoleView:new(cfg, ctrl)
  local conf = {
  }
  for k, v in pairs(cfg) do
    conf[k] = v
  end

  local FAC = conf.fac
  G.scale(FAC, FAC)
  G.setFont(conf.font_main)

  local BORDER = conf.border
  conf.fac = FAC
  conf.border = BORDER
  conf.width = G.getWidth()
  conf.height = G.getHeight()

  local view = {
    title = TitleView,
    canvas = CanvasView:new(conf),
    input = InputView:new(conf, ctrl),
    controller = ctrl,
    cfg = conf,
  }

  setmetatable(view, self)
  self.__index = self

  return view
end

function ConsoleView:draw()
  G.scale(self.fac, self.fac)

  local terminal = self.controller:get_terminal()
  if love.DEBUG then
    self:draw_placeholder()
  end
  self.canvas:draw(terminal)
  self.input:draw(self.controller:get_input())
end

function ConsoleView:draw_placeholder()
  local band = self.cfg.fh
  local w = self.cfg.w
  local h = self.cfg.h
  G.push('all')
  love.graphics.setColor(Color[Color.yellow])
  for o = -h, w, 2 * band do
    love.graphics.polygon("fill"
    , o + 0, h
    , o + h, 0
    , o + h + band, 0
    , o + band, h
    )
  end
  G.pop()
end
