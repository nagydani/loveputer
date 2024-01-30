require("view.canvas.bgView")

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
  local colors = cfg.view.colors

  local drawTerminal = function()
    G.setCanvas()
    G.translate(b, b)
    G.push('all')

    if snapshot then
      G.draw(snapshot)
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

  G.push('all')
  drawTerminal()
  self.bg:draw(drawable_height)
  G.pop()
end
