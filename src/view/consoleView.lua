require("view/color")
require("view/titleView")
require("view/canvasView")
require("view/inputView")

require("util/debug")

local G = love.graphics

ConsoleView = {}

function ConsoleView:new(cfg, ctrl)
  local view = {
    title = TitleView,
    canvas = CanvasView:new(cfg),
    input = InputView:new(cfg, ctrl),
    controller = ctrl,
    cfg = cfg,
  }

  setmetatable(view, self)
  self.__index = self

  return view
end

function ConsoleView:draw(terminal, input)
  G.scale(self.fac, self.fac)

  if love.DEBUG then
    self:draw_placeholder()
  end
  self.canvas:draw(terminal)
  self.input:draw(input)
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
