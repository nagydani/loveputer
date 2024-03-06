require("view.canvas.bgView")

require("util.view")

local G = love.graphics

--- @class CanvasView
--- @field cfg Config
--- @field bg BGView
--- @field draw function
CanvasView = {}

function CanvasView:new(cfg)
  local cv = {
    cfg = cfg,
    bg = BGView.new(cfg)
  }
  setmetatable(cv, self)
  self.__index = self

  return cv
end

--- @param terminal table
--- @param drawable_height number
--- @param snapshot love.Image?
function CanvasView:draw(terminal, drawable_height, snapshot)
  local cfg = self.cfg
  local b = cfg.view.border

  local drawTerminal = function()
    G.reset()
    G.setCanvas()
    G.translate(b, b)
    G.push('all')

    if snapshot then
      terminal:draw(true)
      G.setBlendMode('screen')
    else
      terminal:draw()
      G.setBlendMode('alpha')
    end
    G.draw(terminal.canvas)
    G.pop()
  end

  G.reset()
  G.push('all')
  if ViewUtils.conditional_draw('show_canvas') then
    if snapshot then
      G.draw(snapshot)
    end
    self.bg:draw(drawable_height)
  end
  if ViewUtils.conditional_draw('show_terminal') then
    drawTerminal()
  end
  G.pop()
end
