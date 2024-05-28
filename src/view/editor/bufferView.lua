--- @class BufferView
--- @field visible VisibleContent
--- @field more {up: boolean, down: boolean}
--- @field offset integer
--- @field was_scrolled boolean
--- @field LINES integer
--- @field SCROLL_BY integer
--- @field cfg ViewConfig
---
--- @field draw function
BufferView = {}
BufferView.__index = BufferView

setmetatable(BufferView, {
  __call = function(cls, ...)
    return cls.new(...)
  end,
})

--- @param cfg ViewConfig
function BufferView.new(cfg)
  local l = cfg.lines

  local self = setmetatable({
    LINES = l,
    SCROLL_BY = math.floor(l / 2),

    cfg = cfg
  }, BufferView)
  return self
end

--- @param buffer BufferModel
function BufferView:draw(buffer)
  local G = love.graphics
  local colors = self.cfg.colors.editor
  local font = self.cfg.font
  local fh = self.cfg.fh * 1.032 -- magic constant
  local content = buffer:get_content()
  local last_line_n = #content - 1
  -- TODO visible
  local width, height = G.getDimensions()


  local draw_background = function()
    G.push('all')
    G.setColor(colors.bg)
    G.rectangle("fill", 0, 0, width, height)
    G.setColor(Color.with_alpha(colors.fg, .0625))
    local bh = math.min(last_line_n, self.cfg.lines) * fh
    G.rectangle("fill", 0, 0, width, bh)
    G.pop()
  end
  local draw_highlight = function(line)
    if not line then return end
    local l_y = (line - 1) * fh

    G.setColor(colors.highlight)
    G.rectangle('fill', 0, l_y, width, fh)
  end
  local draw_text = function()
    G.setFont(font)
    G.setColor(colors.fg)
    local text = string.join(content, '\n')

    G.print(text)
  end

  draw_background()
  for _, s in ipairs(buffer.selection) do
    draw_highlight(s)
  end
  draw_text()
end
