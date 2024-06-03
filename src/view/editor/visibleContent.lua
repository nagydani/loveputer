require("view.editor.range")

require("util.wrapped_text")
require("util.table")

--- @class VisibleContent: WrappedText
--- @field range Range?
---
--- @field set_range function(s: integer, e: integer)
--- @field get_visible function(): string[]

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
function VisibleContent.new(w, fulltext)
  local self = setmetatable({
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

function VisibleContent:get_visible()
  local si, ei = self.range.start, self.range.fin
  return table.slice(self.text, si, ei)
end
