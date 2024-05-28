--- @class VisibleContent: WrappedText
--- @field range { start: integer, fin: integer }
---
--- @field set_range function(s: integer, e: integer)

VisibleContent = {}
VisibleContent.__index = VisibleContent

setmetatable(VisibleContent, {
  __call = function(cls, ...)
    return cls.new(...)
  end,
})

--- @param s integer
--- @param e integer
function VisibleContent:set_range(s, e)
  if type(s) == 'number' then self.range.start = s end
  if type(e) == 'number' then self.range.fin = e end
end
