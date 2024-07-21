require("view.editor.visibleBlock")

require("util.wrapped_text")
require("util.range")

--- @alias ReverseMap Dequeue<integer>
--- Inverse mapping from line number to block index

--- @class VisibleStructuredContent: WrappedText
--- @field overscroll_max integer
--- @field overscroll integer
--- @field range Range?
--- @field blocks Block[]
--- @field reverse_map ReverseMap
---
--- @field set_range fun(self, Range)
--- @field get_range fun(self): Range
--- @field move_range fun(self, integer): integer
--- @field get_visible fun(self): string[]
--- @field get_visible_blocks fun(self): Block[]
--- @field get_content_length fun(self): integer

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
function VisibleStructuredContent.new(w, blocks, highlighter, overscroll)
  local fulltext = Dequeue.typed('string')
  local revmap = Dequeue.typed('integer')
  local visible_blocks = Dequeue()
  local off = 0
  for bi, v in ipairs(blocks) do
    -- Log.info(bi, v.pos, string.join(v.lines, '\\n'))
    if v.tag == 'chunk' then
      fulltext:append_all(v.lines)
      local hl = highlighter(v.lines)
      local vblock = VisibleBlock(w, v.lines, hl,
        v.pos, v.pos:translate(off))
      off = off + vblock.wrapped.n_breaks
      visible_blocks:append(vblock)
    elseif v.tag == 'empty' then
      fulltext:append('')
      local npos = v.pos:translate(off)
      visible_blocks:append(VisibleBlock(w, { '' }, {}, v.pos, npos))
    end
    if (v.pos) then
      for _, l in ipairs(v.pos:enumerate()) do
        revmap[l] = bi
      end
    end
  end
  local self = setmetatable({
    overscroll_max = overscroll,
    blocks = visible_blocks,
  }, VisibleStructuredContent)
  WrappedText._init(self, w, fulltext)
  self:_init()
  self.reverse_map = revmap

  return self
end

--- @private
function VisibleStructuredContent:_update_meta()
  local rev = self.wrap_reverse
  local fwd = self.wrap_forward
  table.insert(rev, (#(self.text)))
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

  -- local ret = Dequeue.typed('visibleBlock')
  -- for i = self.range.start, self.range.fin do
  --   local ri = self.reverse_map[i]
  --   ret:append(self.blocks[ri])
  -- end
  -- return ret
end

--- @return integer
function VisibleStructuredContent:get_content_length()
  return self:get_text_length()
end