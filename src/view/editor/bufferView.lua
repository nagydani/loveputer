require("view.editor.visibleContent")

require("util.table")
require("util.wrapped_text")

--- @class BufferView
--- @field visible VisibleContent
--- @field more {up: boolean, down: boolean}
--- @field offset integer
--- @field was_scrolled boolean
--- @field LINES integer
--- @field SCROLL_BY integer
--- @field cfg ViewConfig
--- @field buffer BufferModel
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
    visible = nil,
    more = { up = false, down = false },
    offset = 0,
    was_scrolled = false,

    cfg = cfg,
    buffer = nil
  }, BufferView)
  return self
end

--- @param buffer BufferModel
function BufferView:open(buffer)
  local L = self.LINES
  if buffer then
    self.buffer = buffer
  end
  local content = self.buffer:get_content()
  local clen = #content
  self.offset = math.max(clen - L, 0)
  local off = self.offset
  if off > 0 then
    self.more.up = true
  end
  -- TODO visible
  local si = 1 + off
  local ei = math.min(L, clen) + off
  if ei == clen then ei = ei - 1 end
  local vis = table.slice(content, si, ei)
  self.visible = WrappedText(64, vis)
  self.visible:set_range(si, ei)
end

function BufferView:draw()
  local G = love.graphics
  local colors = self.cfg.colors.editor
  local font = self.cfg.font
  local fh = self.cfg.fh * 1.032 -- magic constant
  local content = self.visible:get_text()
  local last_line_n = #content
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
  for _, s in ipairs(self.buffer.selection) do
    -- TODO multiline
    draw_highlight(s - self.offset)
  end
  draw_text()
end
