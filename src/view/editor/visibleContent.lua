require("util.wrapped_text")
require("util.scrollable")
require("util.range")

--- @class VisibleContent: WrappedText
--- @field range Range?
--- @field size_max integer
--- @field overscroll_max integer
--- @field overscroll integer
---
--- @field get_default_range fun(self): Range
--- @field check_range fun(self)
--- @field wrap fun(self, text: Dequeue<string>)
--- @field set_range fun(self, Range)
--- @field get_range fun(self): Range
--- @field set_default_range fun(self)
--- @field move_range fun(self, integer): integer
--- @field get_content_length fun(self): integer
--- @field get_visible fun(self): Dequeue<string>
--- @field get_more fun(self): More
--- @field to_end fun(self)
VisibleContent = {}
VisibleContent.__index = VisibleContent

setmetatable(VisibleContent, {
  __index = WrappedText,
  __call = function(cls, ...)
    return cls.new(...)
  end,
})

--- @param w integer
--- @param fulltext string[]
--- @param overscroll integer
--- @param size_max integer
--- @return VisibleContent
function VisibleContent.new(w, fulltext, overscroll, size_max)
  --- @type VisibleContent
  --- @diagnostic disable-next-line: assign-type-mismatch
  local self = setmetatable({
    overscroll_max = overscroll,
    size_max = size_max,
    offset = 0,
  }, VisibleContent)
  WrappedText._init(self, w, fulltext)
  self:_init()
  self:to_end()


  return self
end

function VisibleContent:get_default_range()
  local L = math.min(self.size_max, self:get_content_length())
  return Range(1, L)
end

--- Set the visible range so that last of the content is visible
function VisibleContent:to_end()
  self.range = Scrollable.to_end(
    self.size_max, self:get_text_length())
  self.offset = self.range.start - 1
end

--- Invoked after text changes, validate range
function VisibleContent:check_range()
  local l = self:get_text_length()
  local r = self.range
  if r then
    local rl = r:len()
    if r.fin > l then
      r.fin = l
    end
    if rl < self.size_max then
      self:set_default_range()
    end
  else
    self:set_default_range()
  end
end

--- @private
function VisibleContent:_update_meta()
  local rev = self.wrap_reverse
  local fwd = self.wrap_forward
  table.insert(rev, (#(self.text)))
  table.insert(fwd, { #(self.text) + 1 })
  self:_update_overscroll()
end

--- @protected
function VisibleContent:_update_overscroll()
  local len = self:get_text_length()
  local over = math.min(self.overscroll_max, len)
  self.overscroll = over
end

--- @protected
function VisibleContent:_init()
  self:_update_overscroll()
end

function VisibleContent:wrap(text)
  WrappedText.wrap(self, text)
  self:_update_meta()
end

function VisibleContent:get_range()
  return self.range
end

function VisibleContent:set_range(r)
  if r then
    self.offset = r.start - 1
    self.range = r
  end
end

function VisibleContent:set_default_range()
  self.range = self:get_default_range()
  self.offset = 0
end

function VisibleContent:move_range(by)
  if type(by) == "number" then
    local r = self.range
    local upper = self:get_text_length() + self.overscroll
    if r then
      local nr, n = r:translate_limit(by, 1, upper)
      self:set_range(nr)
      return n
    end
  end
  return 0
end

function VisibleContent:get_visible()
  local si, ei = self.range.start, self.range.fin
  return table.slice(self.text, si, ei)
end

function VisibleContent:get_content_length()
  return self:get_text_length()
end

function VisibleContent:get_more()
  local vrange = self:get_range()
  local vlen = self:get_content_length()
  local more = {
    up = vrange.start > 1,
    down = vrange.fin < vlen
  }
  return more
end
