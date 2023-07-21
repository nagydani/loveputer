local G = love.graphics

CanvasView = {}

function CanvasView:new(cfg)
  local cv = {
    cfg = cfg,
  }
  setmetatable(cv, self)
  self.__index = self

  local w = G.getWidth() - 2 * cfg.border
  local h = cfg.get_drawable_height() + cfg.fh

  cv.w = w
  cv.h = h

  return cv
end

function CanvasView:draw(canvas)
  local b = self.cfg.border
  local tf = love.math.newTransform()

  G.push('all')
  G.setCanvas()
  tf:translate(b, b)
  G.draw(canvas, tf)
  G.pop()
end
