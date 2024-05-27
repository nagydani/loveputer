require("view.titleView")
require("view.editorView")
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
--- @field editor EditorView
--- @field controller ConsoleController
--- @field cfg Config
--- @field drawable_height number
ConsoleView = {}
ConsoleView.__index = ConsoleView

setmetatable(ConsoleView, {
  __call = function(cls, ...)
    return cls.new(...)
  end,
})

--- @param cfg Config
--- @param ctrl ConsoleController
function ConsoleView.new(cfg, ctrl)
  local self = setmetatable({
    title = TitleView,
    canvas = CanvasView:new(cfg),
    interpreter = InterpreterView:new(cfg.view, ctrl),
    editor = EditorView(cfg.view, ctrl.editor),
    controller = ctrl,
    cfg = cfg,
    drawable_height = ViewUtils.get_drawable_height(cfg.view),
  }, ConsoleView)

  return self
end

--- @param terminal table
--- @param canvas love.Canvas
--- @param input InputDTO
--- @param snapshot love.Image?
function ConsoleView:draw(terminal, canvas, input, snapshot)
  G.reset()
  if love.DEBUG then
    self:draw_placeholder()
  end

  local function drawConsole()
    local tc = self.controller.model.output.term_canvas
    self.canvas:draw(terminal, canvas, tc, self.drawable_height, snapshot)

    if ViewUtils.conditional_draw('show_input') then
      self.interpreter:draw(input)
    end
  end

  local function drawEditor()
    self.editor:draw()
  end

  if love.state.app_state == 'editor' then
    drawEditor()
  else
    drawConsole()
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
