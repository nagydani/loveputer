require("view.editor.visibleContent")
require("view.editor.visibleStructuredContent")

require("util.table")

--- @class BufferView
--- @field cfg ViewConfig
---
--- @field content VisibleContent|VisibleStructuredContent
--- @field content_type ContentType
--- @field buffer BufferModel
---
--- @field LINES integer
--- @field SCROLL_BY integer
--- @field w integer
--- @field offset integer
--- @field more More
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
    content_type = nil,
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

--- @private
--- @return Range
function BufferView:_calculate_end_range()
  local L = self.LINES
  local clen = self.content:get_text_length()
  local off = math.max(clen - L, 0)
  if off > 0 then off = off + 1 end
  local si = 1 + off
  local ei = math.min(L, clen + 1) + off
  return Range(si, ei)
end

--- @param buffer BufferModel
function BufferView:open(buffer)
  local L = self.LINES
  self.buffer = buffer
  if not self.buffer then
    error('no buffer')
  end
  local cont = buffer.content_type
  self.content_type = cont

  local bufcon = buffer:get_content()
  if cont == 'plain' then
    self.content = VisibleContent(
      self.w, bufcon, self.SCROLL_BY)
  elseif cont == 'lua' then
    self.content =
        VisibleStructuredContent(
          self.w,
          bufcon,
          buffer.highlighter,
          self.SCROLL_BY)
  else
    error 'unknown filetype'
  end

  local clen = self.content:get_text_length()
  self.offset = math.max(clen - L, 0)
  local off = self.offset
  if off > 0 then
    self.more.up = true
    self.offset = off + 1
    off = off + 1
  end

  local ir = self:_calculate_end_range()
  self:_update_visible(ir)
end

function BufferView:refresh()
  if not self.content then
    error('no buffer is open')
  end
  self.content:wrap(self.buffer:get_text_content())
  local clen = self.content:get_content_length()
  local off = self.offset
  local si = 1 + off
  local ei = math.min(self.LINES, clen + 1) + off
  self:_update_visible(Range(si, ei))
  if self.content_type == 'lua' then
    self.content:load_blocks(self.buffer.content)
  end
end

function BufferView:follow_selection()
  local sel = self.buffer:get_selection()
  local r = self.content:get_range()
  local s_w
  if self.content_type == 'lua'
  then
    s_w = self.content:get_block_app_pos(sel):enumerate()
  elseif self.content_type == 'plain'
  then
    s_w = self.content.wrap_forward[sel]
  end
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
--- @param warp boolean?
function BufferView:_scroll(dir, by, warp)
  local by = by or self.SCROLL_BY
  local l = self.content:get_content_length()
  local n = (function()
    if dir == 'up' then
      if warp then
        return -l
      else
        return -by
      end
    else
      if warp then
        local ir = self:_calculate_end_range()
        local c = self.content:get_range()
        return ir.start - c.start
      else
        return by
      end
    end
  end)()
  local o = self.content:move_range(n)
  self.offset = self.offset + o
end

function BufferView:draw()
  local G = love.graphics
  local cf_colors = self.cfg.colors
  local colors = cf_colors.editor
  local font = self.cfg.font
  local fh = self.cfg.fh * 1.032 -- magic constant
  local fw = self.cfg.fw
  local vc = self.content
  --- @type VisibleContent|VisibleStructuredContent
  local content_text = vc:get_visible()
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

  local draw_highlight = function()
    local highlight_line = function(ln)
      if not ln then return end
      G.setColor(colors.highlight)
      local l_y = (ln - 1) * fh
      G.rectangle('fill', 0, l_y, width, fh)
    end

    local off = self.offset
    local ws = self:get_wrapped_selection()
    for _, w in ipairs(ws) do
      for _, v in ipairs(w) do
        if self.content.range:inc(v) then
          if (not self.cfg.show_append_hl)
              and (v == self.content:get_content_length() + 1) then
            --- skip hl
          else
            highlight_line(v - off)
          end
        end
      end
    end
  end

  local draw_text = function()
    G.setFont(font)
    if self.content_type == 'lua' then
      --- @type VisibleBlock[]
      local vbl = vc:get_visible_blocks()
      for _, block in ipairs(vbl) do
        local rs = block.app_pos.start
        --- @type WrappedText
        local wt = block.wrapped
        for l, line in ipairs(wt:get_text()) do
          local ln = rs + (l - 1) - self.offset
          for ci = 1, string.ulen(line) do
            local char = string.usub(line, ci, ci)
            local hl = block.highlight
            if hl then
              local lex_t = (function()
                if hl[l] then
                  return hl[l][ci] or colors.fg
                end
                return colors.fg
              end)()
              local color =
                  cf_colors.input.syntax[lex_t] or colors.fg

              G.setColor(color)
            else
              G.setColor(colors.fg)
            end
            G.print(char, (ci - 1) * fw, (ln - 1) * fh)
          end
        end
      end -- for

      if love.DEBUG then
        --- phantom text
        G.setColor(Color.with_alpha(colors.fg, 0.3))
        local text = string.unlines(content_text)
        G.print(text)
      end
    elseif self.content_type == 'plain' then
      G.setColor(colors.fg)
      local text = string.unlines(content_text)

      G.print(text)
    end
  end

  local draw_debuginfo = function()
    if not love.DEBUG then return end
    local showap = false
    local lnc = colors.fg
    local x = self.cfg.w - font:getWidth('   ') - 3
    local lnvc = Color.with_alpha(lnc, 0.2)
    G.rectangle("fill", x, 0, 2, self.cfg.h)
    local seen = {}
    for ln = 1, self.LINES do
      local l_y = (ln - 1) * fh
      local vln = ln + self.offset
      local ln_w = self.content.wrap_reverse[vln]
      if ln_w then
        local l = string.format('%3d', ln_w)
        local l_x = self.cfg.w - font:getWidth(l)
        local l_xv = l_x - font:getWidth(l) - 3.5
        if showap then
          G.setColor(lnvc)
          G.print(string.format('%3d', vln), l_xv, l_y)
        end
        if not seen[ln_w] then
          G.setColor(lnc)
          G.print(l, l_x, l_y)
          seen[ln_w] = true
        end
      end
    end
  end

  draw_background()
  draw_highlight()
  draw_text()
  draw_debuginfo()
end

--- @return integer[][]
function BufferView:get_wrapped_selection()
  local sel = self.buffer:get_selection()
  local cont = self.content
  local ret = {}
  if self.content_type == 'lua'
  then
    --- @type Range?
    local br = cont:get_block_pos(sel)
    if br then
      for _, l in ipairs(br:enumerate()) do
        table.insert(ret, self.content.wrap_forward[l])
      end
    end
  elseif self.content_type == 'plain'
  then
    ret[1] = self.content.wrap_forward[sel]
  end
  return ret
end
