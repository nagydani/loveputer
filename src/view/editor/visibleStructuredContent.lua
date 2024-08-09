require("view.editor.visibleBlock")

require("util.wrapped_text")
require("util.range")

--- @alias ReverseMap Dequeue<integer>
--- Inverse mapping from line number to block index

--- @class VisibleStructuredContent: WrappedText
--- @field overscroll_max integer
--- @field overscroll integer
--- @field range Range?
--- @field blocks VisibleBlock[]
--- @field reverse_map ReverseMap
---
--- @field set_range fun(self, Range)
--- @field get_range fun(self): Range
--- @field move_range fun(self, integer): integer
--- @field load_blocks fun(self, blocks: Block[])
--- @field get_visible fun(self): string[]
--- @field get_visible_blocks fun(self): Block[]
--- @field get_content_length fun(self): integer
--- @field get_block_pos fun(self, integer): Range?
--- @field get_block_app_pos fun(self, integer): Range?
--- @field get_more fun(self): More

VisibleStructuredContent = {}
VisibleStructuredContent.__index = VisibleStructuredContent

setmetatable(VisibleStructuredContent, {
  __index = WrappedText,
  __call = function(cls, ...)
    return cls.new(...)
  end,
})

--- @param w integer
--- @param blocks Block[]
--- @param highlighter fun(c: string[]): SyntaxColoring
--- @return VisibleStructuredContent
function VisibleStructuredContent.new(w, blocks,
                                      highlighter, overscroll)
  local self = setmetatable({
    highlighter = highlighter,
    overscroll_max = overscroll,
    w = w,
  }, VisibleStructuredContent)
  self:load_blocks(blocks)

  return self
end

--- Process a list of blocks into VisibleBlocks
--- @param blocks Block[]
function VisibleStructuredContent:load_blocks(blocks)
  local fulltext = Dequeue.typed('string')
  local revmap = Dequeue.typed('integer')
  local visible_blocks = Dequeue()
  local off = 0
  for bi, v in ipairs(blocks) do
    if v.tag == 'chunk' then
      fulltext:append_all(v.lines)
      local hl = self.highlighter(v.lines)
      local vblock = VisibleBlock(self.w, v.lines, hl,
        v.pos, v.pos:translate(off))
      off = off + vblock.wrapped.n_breaks
      visible_blocks:append(vblock)
    elseif v.tag == 'empty' then
      fulltext:append('')
      local npos = v.pos:translate(off)
      visible_blocks:append(
        VisibleBlock(self.w, { '' }, {}, v.pos, npos))
    end
    if (v.pos) then
      for _, l in ipairs(v.pos:enumerate()) do
        revmap[l] = bi
      end
    end
  end
  WrappedText._init(self, self.w, fulltext)
  self:_init()
  self.reverse_map = revmap
  self.blocks = visible_blocks
end

--- @private
function VisibleStructuredContent:_update_meta()
  local rev = self.wrap_reverse
  local rl = #rev
  local fwd = self.wrap_forward
  table.insert(rev, ((rev[rl] or 0) + 1))
  table.insert(fwd, { #(self.text) + 1 })
  self:_update_overscroll()
end

--- @protected
function VisibleStructuredContent:_update_overscroll()
  local len = WrappedText.get_text_length(self)
  local over = math.min(self.overscroll_max, len)
  self.overscroll = over
end

--- @protected
function VisibleStructuredContent:_init()
  self:_update_overscroll()
end

--- @param text string[]
function VisibleStructuredContent:wrap(text)
  WrappedText.wrap(self, text)

  self:_update_meta()
end

--- @return Range
function VisibleStructuredContent:get_range()
  return self.range
end

--- @param r Range
function VisibleStructuredContent:set_range(r)
  self.range = r
end

--- @param by integer
--- @return integer n
function VisibleStructuredContent:move_range(by)
  if type(by) == "number" then
    local r = self.range
    local upper = self:get_text_length() + self.overscroll
    local nr, n = r:translate_limit(by, 1, upper)
    self:set_range(nr)
    return n
  end
  return 0
end

--- @return string[]
function VisibleStructuredContent:get_visible()
  local si, ei = self.range.start, self.range.fin
  return table.slice(self.text, si, ei)
end

--- @return VisibleBlock[]
function VisibleStructuredContent:get_visible_blocks()
  local si = self.wrap_reverse[self.range.start]
  local ei = self.wrap_reverse[self.range.fin]
  local sbi, sei = self.reverse_map[si], self.reverse_map[ei]
  return table.slice(self.blocks, sbi, sei)
end

--- @return integer
function VisibleStructuredContent:get_content_length()
  return self:get_text_length()
end

--- @param bn integer
--- @return Range?
function VisibleStructuredContent:get_block_pos(bn)
  local cl = #(self.blocks)
  if bn > 0 and bn <= cl then
    return self.blocks[bn].pos
  elseif bn == cl + 1 then
    return Range.singleton(self.blocks[cl].pos.fin + 1)
  end
end

--- @param bn integer
--- @return Range?
function VisibleStructuredContent:get_block_app_pos(bn)
  local cl = #(self.blocks)
  if bn > 0 and bn <= cl then
    return self.blocks[bn].app_pos
  elseif bn == cl + 1 then
    local wr = self.wrap_reverse
    return Range.singleton(#wr)
  end
end

--- @return More
function VisibleStructuredContent:get_more()
  local vrange = self:get_range()
  local vlen = self:get_content_length()
  local more = {
    up = vrange.start > 1,
    down = vrange.fin < vlen
  }
  return more
end
