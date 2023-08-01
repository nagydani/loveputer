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

function CanvasView:draw(terminal)
  local b = self.cfg.border
  local tf = love.math.newTransform()

  G.push('all')
  G.setCanvas()
  G.translate(b, b)
  terminal:draw()
  G.pop()
end
