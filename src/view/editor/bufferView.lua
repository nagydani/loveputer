require("view.editor.visibleContent")

require("util.table")

--- @class BufferView
--- @field cfg ViewConfig
--- @field LINES integer
--- @field SCROLL_BY integer
--- @field w integer
---
--- @field content VisibleContent
--- @field more More
--- @field offset integer
--- @field buffer BufferModel
---
--- @field open function
--- @field refresh function
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
    cfg = cfg,
    LINES = l,
    SCROLL_BY = math.floor(l / 2),
    w = cfg.drawableChars,

    content = nil,
    more = { up = false, down = false },
    offset = 0,
    buffer = nil
  }, BufferView)
  return self
end

--- @private
--- @param r Range
function BufferView:_update_visible(r)
  self.content:set_range(r)
end

--- @param buffer BufferModel
function BufferView:open(buffer)
  local L = self.LINES
  self.buffer = buffer
  if not self.buffer then
    error('no buffer')
  end

  self.content = VisibleContent(self.w, buffer:get_content(), self.SCROLL_BY)
  local clen = self.content:get_text_length()
  self.offset = math.max(clen - L, 0)
  local off = self.offset
  if off > 0 then
    self.more.up = true
    self.offset = off + 1
    off = off + 1
  end

  local si = 1 + off
  local ei = math.min(L, clen + 1) + off
  self:_update_visible(Range(si, ei))
end

function BufferView:refresh()
  if not self.content or not self.content.range then
    error('no buffer is open')
  end
  self.content:wrap(self.buffer:get_content())
  local clen = self.content:get_content_length()
  local off = self.offset
  local si = 1 + off
  local ei = math.min(self.LINES, clen + 1) + off
  self:_update_visible(Range(si, ei))
end

function BufferView:follow_selection()
  local sel = self.buffer:get_selection()
  local r = self.content:get_range()
  -- TODO multiline
  local s_w = self.content.wrap_forward[sel[1]]
  local sel_s = s_w[1]
  local sel_e = s_w[#s_w]
  if r:inc(sel_s) and r:inc(sel_e) then return end
  --- @type VerticalDir
  local dir = (function()
    if r.start > sel_s then return 'up' end
    if r.fin < sel_e then return 'down' end
  end)()
  if dir == 'up' then
    local d = r.start - sel_s
    self:_scroll(dir, d)
  elseif dir == 'down' then
    local d = sel_e - r.fin
    self:_scroll(dir, d)
  end
end

--- @param dir VerticalDir
--- @param by integer?
function BufferView:_scroll(dir, by)
  local by = by or self.SCROLL_BY
  local n = (function()
    if dir == 'up' then
      return -by
    else
      return by
    end
  end)()
  local o = self.content:move_range(n)
  self.offset = self.offset + o
end

function BufferView:draw()
  local G = love.graphics
  local colors = self.cfg.colors.editor
  local font = self.cfg.font
  local fh = self.cfg.fh * 1.032 -- magic constant
  local content_text = self.content:get_visible()
  local last_line_n = #content_text
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
    G.setColor(colors.highlight)
    local l_y = (line - 1) * fh

    G.rectangle('fill', 0, l_y, width, fh)
  end
  local draw_text = function()
    G.setFont(font)
    G.setColor(colors.fg)
    local text = string.unlines(content_text)

    G.print(text)
  end

  draw_background()
  local off = self.offset
  local ws = self:get_wrapped_selection()
  for _, w in ipairs(ws) do
    for _, v in ipairs(w) do
      if self.content.range:inc(v) then
        draw_highlight(v - off)
      end
    end
  end
  draw_text()
end

--- @return integer[][]
function BufferView:get_wrapped_selection()
  local ret = {}
  local sel = self.buffer:get_selection()
  for i, v in ipairs(sel) do
    ret[i] = self.content.wrap_forward[v]
  end
  return ret
end

