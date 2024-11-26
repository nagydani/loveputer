local class = require('util.class')

--- @param cfg ViewConfig
local new = function(cfg)
  return {
    cfg = cfg
  }
end

--- @class ResultsView
--- @field cfg ViewConfig
ResultsView = class.create(new)

function ResultsView:draw()
  local cf_colors = self.cfg.colors
  local colors = cf_colors.editor.results
  local width, height = G.getDimensions()

  local draw_background = function()
    G.push('all')
    G.setColor(colors.bg)
    G.rectangle("fill", 0, 0, width, height)
    G.pop()
  end

  draw_background()
end
