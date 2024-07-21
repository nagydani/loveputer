require("util.range")
require("util.string")

--- @class VisibleBlock
--- @field wrapped WrappedText
--- @field highlight SyntaxColoring
--- @field pos Range
--- @field app_pos Range
VisibleBlock = {}
VisibleBlock.__index = VisibleBlock

setmetatable(VisibleBlock, {
  __call = function(cls, ...)
    return cls.new(...)
  end,
})

--- @param w integer
--- @param lines string|string[]
--- @param pos Range
--- @return VisibleBlock
function VisibleBlock.new(w, lines, hl, pos, apos)
  local ls = (function()
    if type(lines) == 'string' then return { lines } end
    return lines
  end)()

  local wrapped_text = WrappedText(w, ls)
  local wrapped_highlight = {}
  if wrapped_text.n_breaks > 0 then
    for ln, line in ipairs(wrapped_text.text) do
      local rln = wrapped_text.wrap_reverse[ln]
      wrapped_highlight[ln] = {}
      for i = 1, string.ulen(line) do
        local rank = wrapped_text.wrap_rank[ln]
        local c = i + rank * w
        wrapped_highlight[ln][i] = hl[rln][c]
      end
    end
  else
    wrapped_highlight = hl
  end

  local self = setmetatable({
    wrapped = wrapped_text,
    highlight = wrapped_highlight,
    pos = pos,
    app_pos = apos,
  }, VisibleBlock)

  return self
end

function VisibleBlock:__tostring()
  local r = string.format("%s\t%s",
    tostring(self.pos),
    tostring(self.app_pos)
  )
  local l1 = self.wrapped.text[1]
  local txt
  if string.is_non_empty_string(l1) then
    txt = l1
    if self.wrapped.text[2] then
      txt = txt .. '...'
    end
  else
    txt = '<empty>'
  end
  return string.format("%s\t%s", r, txt)
end
