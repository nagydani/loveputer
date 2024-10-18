require("view.canvas.bgView")
require("view.canvas.terminalView")

local class = require("util.class")
require("util.view")

local G = love.graphics

--- @class CanvasView
--- @field cfg Config
--- @field bg BGView
--- @field draw function
CanvasView = class.create(function(cfg)
  return {
    cfg = cfg,
    bg = BGView(cfg)
  }
end)

--- @param terminal table
--- @param canvas love.Canvas
--- @param term_canvas love.Canvas
--- @param drawable_height number
--- @param snapshot love.Image?
function CanvasView:draw(
    terminal, canvas, term_canvas, drawable_height, snapshot
)
  local cfg = self.cfg
  local test = cfg.drawtest
  local vcfg = cfg.view

  G.reset()
  G.push('all')
  G.setBlendMode('alpha', 'alphamultiply') -- default
  if ViewUtils.conditional_draw('show_snapshot') then
    if snapshot then
      G.draw(snapshot)
    end
    self.bg:draw(drawable_height)
  end

  if not test then
    if ViewUtils.conditional_draw('show_terminal') then
      -- G.setBlendMode('multiply', "premultiplied")
      TerminalView.draw(terminal, term_canvas, snapshot)
    end
    if ViewUtils.conditional_draw('show_canvas') then
      G.draw(canvas)
    end
    G.setBlendMode('alpha', 'alphamultiply') -- default
  else
    G.setBlendMode('alpha', 'alphamultiply') -- default
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
          -- G.setBlendMode('alpha') -- default
          if ViewUtils.conditional_draw('show_terminal') then
            b.blend()
            TerminalView.draw(terminal, term_canvas, snapshot)
          end
          G.setBlendMode('alpha') -- default
          if ViewUtils.conditional_draw('show_canvas') then
            G.draw(canvas)
          end

          G.setBlendMode('alpha') -- default
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
