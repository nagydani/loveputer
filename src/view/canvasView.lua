local G = love.graphics

CanvasView = {}

function CanvasView:new(cfg)
  local cv = {
    cfg = cfg
  }
  setmetatable(cv, self)
  self.__index = self

  return cv
end

function CanvasView:draw(terminal)
  local b = self.cfg.border

  G.push('all')
  G.setCanvas()
  G.translate(b, b)
  terminal:draw()
  G.pop()
end
