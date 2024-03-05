require("view.titleView")
require("view.canvas.canvasView")
require("view.input.interpreterView")
require("util.color")
require("util.view")
require("util.debug")

local G = love.graphics

--- @class ConsoleView
--- @field title table
--- @field canvas CanvasView
--- @field interpreter InterpreterView
--- @field controller ConsoleController
--- @field cfg Config
--- @field drawable_height number
ConsoleView = {}

--- @param cfg Config
--- @param ctrl ConsoleController
function ConsoleView:new(cfg, ctrl)
  local view = {
    title = TitleView,
    canvas = CanvasView:new(cfg),
    interpreter = InterpreterView:new(cfg, ctrl),
    controller = ctrl,
    cfg = cfg,
    drawable_height = ViewUtils.get_drawable_height(cfg.view),
  }

  setmetatable(view, self)
  self.__index = self

  return view
end

--- @param terminal table
--- @param input InputDTO
--- @param snapshot love.Image?
function ConsoleView:draw(terminal, input, snapshot)
  G.reset()
  if love.DEBUG then
    self:draw_placeholder()
  end
  self.canvas:draw(terminal, self.drawable_height, snapshot)
  if ViewUtils.conditional_draw('show_input') then
    self.interpreter:draw(input)
  end
end

function ConsoleView:draw_placeholder()
  local band = self.cfg.view.fh
  local w    = self.cfg.view.w
  local h    = self.cfg.view.h
  G.push('all')
  G.setColor(Color[Color.yellow])
  for o = -h, w, 2 * band do
    G.polygon("fill"
    , o + 0, h
    , o + h, 0
    , o + h + band, 0
    , o + band, h
    )
  end
  G.pop()
end
