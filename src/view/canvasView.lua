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

  local drawTerminal = function()
    G.setCanvas()
    G.translate(b, b)
    G.push('all')

    terminal:set_cursor_color(unpack(cfg.colors.terminal.fg))
    terminal:set_cursor_backcolor(unpack(cfg.colors.terminal.bg))
    terminal:draw()
    G.pop()
  end
  local drawBackground = function()
    G.push('all')
    G.setColor(cfg.colors.terminal.bg)

    G.rectangle("fill",
      b,
      b + cfg.get_drawable_height() - 2 * cfg.fac,
      cfg.w - b,
      cfg.fh
    )
    G.pop()
  end

  G.push('all')
  drawTerminal()
  drawBackground()
  G.pop()
end
