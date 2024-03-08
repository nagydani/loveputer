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
--- @param canvas love.Canvas
--- @param drawable_height number
--- @param snapshot love.Image?
function CanvasView:draw(terminal, canvas, drawable_height, snapshot)
  local cfg = self.cfg
  local test = cfg.drawtest
  local vcfg = cfg.view

  local drawTerminal = function()
    G.setCanvas()
    G.push('all')

    if snapshot then
      terminal:draw(true)
    else
      terminal:draw()
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

  if not test then
    if ViewUtils.conditional_draw('show_terminal') then
      drawTerminal()
    end
    if ViewUtils.conditional_draw('show_canvas') then
      G.draw(canvas)
    end
  else
    for i = 0, love.test_grid_y - 1 do
      for j = 0, love.test_grid_x - 1 do
        local off_x = vcfg.debugwidth * vcfg.fw
        local off_y = vcfg.debugheight * vcfg.fh
        local dx = j * off_x
        local dy = i * off_y
        G.reset()
        G.translate(dx, dy)

        local index = (i * love.test_grid_x) + j + 1

        local b = ViewUtils.blendModes[index]
        if b then
          if ViewUtils.conditional_draw('show_terminal') then
            b.blend()
            drawTerminal()
          end
          G.setBlendMode('alpha') -- default
          if ViewUtils.conditional_draw('show_canvas') then
            G.draw(canvas)
          end

          G.setColor(1, 1, 1, 1)
          G.setFont(vcfg.labelfont)

          -- G.print(index .. ' ' .. b.name)
          G.print(b.name)
        end
      end
    end
  end

  G.pop()
end
