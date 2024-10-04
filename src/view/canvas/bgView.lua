local class = require("util.class")

--- @class BGView
--- @field cfg Config
BGView = class.create(function(cfg)
  return { cfg = cfg }
end)

function BGView:draw(drawable_height)
  --- @type ViewConfig
  local vcfg = self.cfg.view
  local colors = vcfg.colors
  local b = vcfg.border
  local FAC = vcfg.FAC
  local w = vcfg.w
  local fh = vcfg.fh

  G.push('all')
  G.setColor(colors.border)

  -- background in case input is not visible
  G.rectangle("fill",
    b,
    b + drawable_height - 2 * FAC,
    w - b,
    fh * 2 + 2
  )
  G.pop()
end
