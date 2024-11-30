require("view.editor.visibleContent")
require("view.editor.visibleStructuredContent")

local class = require("util.class")
require("util.scrollable")
require("util.table")
local B = require("util.block")

local function new(cfg)
  local l = cfg.lines

  return {
    cfg = cfg,
    LINES = l,
    SCROLL_BY = math.floor(l / 2),
    w = cfg.drawableChars,

    content = nil,
    content_type = nil,
    more = { up = false, down = false },
    offset = 0,
    buffer = nil
  }
end

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
BufferView = class.create(new)

--- @private
--- @param r Range
function BufferView:_update_visible(r)
  self.content:set_range(r)
end

--- @private
--- @return integer[][]
--- @return boolean loaded_is_sel
function BufferView:_get_wrapped_selection()
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

  local ls = self.buffer:loaded_is_sel(false)
  return ret, ls
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
      self.w, bufcon, self.SCROLL_BY, L)
  elseif cont == 'lua' then
    self.content =
        VisibleStructuredContent(
          self.w,
          bufcon,
          buffer.highlighter,
          self.SCROLL_BY,
          L)
  else
    error 'unknown filetype'
  end

  -- TODO clean this up
  local clen = self.content:get_text_length()
  self.offset = math.max(clen - L, 0)
  local off = self.offset
  if off > 0 then
    self.more.up = true
  end

  local ir = self:_get_end_range()
  self:_update_visible(ir)
  if off > 0 then self:scroll('down', 1) end
end

--- @return BufferState
function BufferView:get_state()
  local buf = self.buffer
  return {
    filename = buf.name,
    selection = buf.selection,
    offset = self.offset,
  }
end

--- @param moved integer?
function BufferView:refresh(moved)
  if not self.content then
    error('no buffer is open')
  end
  local text = self.buffer:get_text_content()
  self.content:wrap(text)
  if self.content_type == 'lua' then
    self.content:load_blocks(self.buffer.content)
  end

  if moved then
    local sel = self.buffer:get_selection()
    if self.content_type == 'plain' then
      local t = Dequeue(text)
      t:move(moved, sel)
      self.content:wrap(t)
    end
    if self.content_type == 'lua' then
      local vsc = self.content
      local blocks = vsc.blocks
      blocks:move(moved, sel)
      vsc:recalc_range()
    end
  end

  local clen = self.content:get_content_length()
  local off = self.offset
  local si = 1 + off
  local ei = math.min(self.LINES, clen + 1) + off
  self:_update_visible(Range(si, ei))
end

-------------------
---  scrolling  ---
-------------------

--- @private
--- @return Range
function BufferView:_get_end_range()
  local clen = self.content:get_text_length()
  return Scrollable.calculate_end_range(self.LINES, clen)
end

--- @param dir VerticalDir
--- @param by integer?
--- @param warp boolean?
function BufferView:scroll(dir, by, warp)
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
      local er = self:_get_end_range()
      local c = self.content:get_range()
      if warp then
        return er.start - c.start - self.LINES
      else
        return by
      end
    end
  end)()
  local o = self.content:move_range(n)
  self.offset = self.offset + o
end

--- @param off integer
function BufferView:scroll_to(off)
  self:scroll('up', nil, true)
  self:scroll('down', off)
end

--- @return boolean
--- @return VerticalDir?
--- @return number? diff
function BufferView:is_selection_visible()
  local sel = self.buffer:get_selection()

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
  local r = self.content:get_range()
  if r:inc(sel_s) and r:inc(sel_e) then return true end

  local dir = (function()
    if r.start > sel_s then return 'up' end
    if r.fin < sel_e then return 'down' end
  end)()
  local d = (function()
    if dir == 'up' then
      return r.start - sel_s
    elseif dir == 'down' then
      --- TODO: smooothen around the end
      local off = self.LINES - 1
      -- local er = self:_get_end_range()
      -- if er:inc(sel_e) then
      --   off = 0 -- self.SCROLL_BY
      -- end
      return sel_s - r.fin + off
    end
  end)()

  return false, dir, d
end

function BufferView:follow_selection()
  local v, dir, d = self:is_selection_visible()
  if not v then
    if dir and d then self:scroll(dir, d) end
  end
end

--- @param special boolean
function BufferView:draw(special)
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
    local ws, ls = self:_get_wrapped_selection()

    local highlight_line = function(ln)
      if not ln then return end
      if special then
        G.setColor(colors.highlight_special)
      else
        if ls then
          G.setColor(colors.highlight_loaded)
        else
          G.setColor(colors.highlight)
        end
      end
      local l_y = (ln - 1) * fh
      G.rectangle('fill', 0, l_y, width, fh)
    end

    local off = self.offset
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
          if ln > self.cfg.lines then return end

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
    G.setColor(lnvc)
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
