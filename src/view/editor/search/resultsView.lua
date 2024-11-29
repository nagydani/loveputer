local class = require('util.class')

--- @param cfg ViewConfig
local new = function(cfg)
  return {
    cfg = cfg
  }
end

--- @class ResultsView : ViewBase
ResultsView = class.create(new)

--- @param results ResultsDTO
function ResultsView:draw(results)
  local colors = self.cfg.colors.editor
  local fh = self.cfg.fh * 1.032 -- magic constant
  local width, height = G.getDimensions()

  local draw_background = function()
    G.push('all')
    G.setColor(colors.results.bg)
    G.rectangle("fill", 0, 0, width, height)
    G.pop()
  end

  local draw_results = function()
    G.push('all')
    G.setColor(colors.results.fg)
    G.setFont(self.cfg.font)
    for i, v in ipairs(results.results) do
      local ln = i
      G.print(v.r.name, 15, (ln - 1) * fh)
    end
    G.pop()
  end


  local draw_selection = function()
    local highlight_line = function(ln)
      if not ln then return end

      G.setColor(colors.highlight)
      local l_y = (ln - 1) * fh
      G.rectangle('fill', 0, l_y, width, fh)
    end
    local off = self.offset or 0
    local v = results.selection
    highlight_line(v - off)
  end

  draw_background()
  draw_selection()
  draw_results()
end
