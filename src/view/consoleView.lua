require("view/color")
require("view/titleView")
require("view/canvasView")
require("view/inputView")

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
  self.canvas:draw(terminal)
  self.input:draw(self.controller:get_input())
end
