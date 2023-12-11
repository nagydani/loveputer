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

function CanvasView:draw(terminal, drawable_height)
  local cfg = self.cfg
  local b = cfg.view.border
  local colors = cfg.view.colors

  local drawTerminal = function()
    G.setCanvas()
    G.translate(b, b)
    G.push('all')

    terminal:set_cursor_color(unpack(colors.terminal.fg))
    terminal:set_cursor_backcolor(unpack(colors.terminal.bg))
    terminal:draw()
    G.pop()
  end
  local drawBackground = function()
    G.push('all')
    G.setColor(colors.terminal.bg)

    local dh = drawable_height
    G.rectangle("fill",
      b,
      b + dh - 2 * cfg.view.fac,
      cfg.view.w - b,
      cfg.view.fh
    )
    G.pop()
  end

  G.push('all')
  drawTerminal()
  drawBackground()
  G.pop()
end
