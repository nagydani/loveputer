require("util.wrapped_text")
require("util.range")

--- @class VisibleContent: WrappedText
--- @field range Range?
---
--- @field set_range fun(self, s: integer, e: integer)
--- @field move_range fun(self, n: integer)
--- @field get_visible fun(self): string[]

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
--- @return VisibleContent
function VisibleContent.new(w, fulltext, overscroll)
  local self = setmetatable({
    overscroll = overscroll
  }, VisibleContent)
  WrappedText._init(self, w, fulltext)
  self:_init()

  return self
end

--- @private
function VisibleContent:_update_meta()
  local rev = self.wrap_reverse
  local fwd = self.wrap_forward
  table.insert(rev, (#(self.text)))
  table.insert(fwd, { #(self.text) + 1 })
end

--- @protected
function VisibleContent:_init()
end

--- @param text string[]
function VisibleContent:wrap(text)
  WrappedText.wrap(self, text)
  self:_update_meta()
end

--- @param r Range
function VisibleContent:set_range(r)
  self.range = r
end

--- @param by integer
--- @return integer n
function VisibleContent:move_range(by)
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
function VisibleContent:get_visible()
  local si, ei = self.range.start, self.range.fin
  return table.slice(self.text, si, ei)
end
