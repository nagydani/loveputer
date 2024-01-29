local G = love.graphics

--- @class CanvasView
--- @field cfg Config
--- @field draw function
CanvasView = {}

function CanvasView:new(cfg)
  local cv = {
    cfg = cfg
  }
  setmetatable(cv, self)
  self.__index = self

  return cv
end

--- @param terminal table
--- @param drawable_height number
--- @param overlay boolean?
function CanvasView:draw(terminal, drawable_height, overlay)
  local cfg = self.cfg
  local b = cfg.view.border
  local colors = cfg.view.colors

  local drawTerminal = function()
    G.setCanvas()
    G.translate(b, b)
    G.push('all')

    if overlay then
      G.setBlendMode('replace')
      local fg = Color.with_alpha(
        colors.terminal.fg, 0.1)
      local bg = Color.with_alpha(
        colors.terminal.bg, 0.1)
      terminal:set_cursor_color(fg)
      terminal:set_cursor_backcolor(bg)
    else
      G.setBlendMode('alpha')
      terminal:set_cursor_color(colors.terminal.fg)
      terminal:set_cursor_backcolor(colors.terminal.bg)
    end
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
