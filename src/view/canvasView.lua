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
  local cfg = self.cfg
  local b = cfg.border

  local drawBackground = function()
    G.push('all')
    G.setColor(cfg.colors.terminal.bg)
    G.rectangle("fill",
      b,
      b + cfg.get_drawable_height(),
      cfg.w - b,
      cfg.fh
    )
    G.pop()
  end

  G.push('all')
  G.setCanvas()
  G.translate(b, b)
  G.push('all')
  terminal:draw()
  G.pop()
  drawBackground()
  G.pop()
end
