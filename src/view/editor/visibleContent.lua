require("util.wrapped_text")

--- @class VisibleContent: WrappedText
--- @field range { start: integer, fin: integer }
---
--- @field set_range function(s: integer, e: integer)

VisibleContent = {}
VisibleContent.__index = VisibleContent

setmetatable(VisibleContent, {
  __index = WrappedText,
  __call = function(cls, ...)
    return cls.new(...)
  end,
})

--- @param w integer
--- @param text string[]?
--- @return VisibleContent
function VisibleContent.new(w, text)
  local self = setmetatable({}, VisibleContent)
  WrappedText._init(self, w, text)
  self:_init()

  local rev = self.wrap_reverse
  local fw = self.wrap_forward
  table.insert(rev, (#text + self.n_breaks))
  table.insert(fw, { #text + self.n_breaks + 1 })
  return self
end

--- @protected
function VisibleContent:_init()
  self.range = { start = 0, fin = 0 }
end

--- @param s integer
--- @param e integer
function VisibleContent:set_range(s, e)
  if type(s) == 'number' then self.range.start = s end
  if type(e) == 'number' then self.range.fin = e end
end
