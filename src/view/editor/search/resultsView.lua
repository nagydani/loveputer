local class = require('util.class')

--- @param cfg ViewConfig
local new = function(cfg)
  return {
    cfg = cfg,
    offset = 0,
  }
end

--- @class ResultsView : ViewBase
--- @field cfg ViewConfig
--- @field offset integer
ResultsView = class.create(new)

--- @param results ResultsDTO
function ResultsView:draw(results)
  local colors = self.cfg.colors.editor
  local fh = self.cfg.fh * 1.032 -- magic constant
  local width, height = G.getDimensions()
  local has_results = (results.results and #(results.results) > 0)

  local draw_background = function()
    G.push('all')
    G.setColor(colors.results.bg)
    G.rectangle("fill", 0, 0, width, height)
    G.pop()
  end

  local draw_results = function()
    local getLabel = function(t)
      if t == 'function' then
        return "☰"
      elseif t == 'method' then
        return "☰"
      elseif t == 'local' then
        return "◊"
      elseif t == 'global' then
        return "⭘"
      elseif t == 'field' then
        return ""
      end
    end
    G.push('all')
    G.setFont(self.cfg.font)
    if not has_results then
      G.setColor(Color.with_alpha(colors.results.fg, 0.5))
      G.print("No results", 25, 0)
    else
      for i, v in ipairs(results.results) do
        local ln = i
        local lh = (ln - 1) * fh
        local t = v.r.type
        local label = getLabel(t)
        G.setColor(Color.with_alpha(colors.results.fg, 0.5))
        G.print(label, 2, lh + 2)
        G.setColor(colors.results.fg)
        G.print(v.r.name, 25, lh)
      end
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
  if has_results then
    draw_selection()
  end
  draw_results()
end
