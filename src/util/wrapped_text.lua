require("util.string")

--- Example text: {
--- 'ABBA',
--- 'EDDA AC/DC',
--- }
--- Assume a wrap width of 5, wrapped text comes out to: {
--- 'ABBA',
--- 'EDDA ',
--- 'AC/DC',
--- }
--- @alias WrapForward integer[][]
--- Mapping from original line numbers to wrapped line numbers.
--- e.g. {1: {1}, 2: {2, 3}}
--- @alias WrapReverse integer[]
--- Inverse mapping from apparent line number to original
--- Key is line number in wrapped, value is line number in
--- unwrapped original, e.g. {1: 1, 2: 2, 3: 2} means two
--- lines of text were broken up into three, because the second
--- exceeded the width limit
--- @alias WrapRank integer[]
--- The number of wraps that produced this line
--- (i.e. offset from the original line number)

--- @class WrappedText
--- @field text string[]
--- @field wrap_w integer
--- @field wrap_forward WrapForward
--- @field wrap_reverse WrapReverse
--- @field wrap_rank WrapRank
--- @field n_breaks integer
---
--- @field wrap function
--- @field get_text function
--- @field get_line function
--- @field get_text_length function
WrappedText = {}
WrappedText.__index = WrappedText

setmetatable(WrappedText, {
  __call = function(cls, ...)
    return cls.new(...)
  end,
})

--- @param w integer
--- @param text string[]?
--- @return WrappedText
function WrappedText.new(w, text)
  local self = setmetatable({}, WrappedText)
  self:_init(w, text)

  return self
end

--- @protected
--- @param w integer
--- @param text string[]?
function WrappedText:_init(w, text)
  if type(w) ~= "number" or w < 1 then
    error('invalid wrap length')
  end
  self.text = {}
  self.wrap_w = w
  self.wrap_forward = {}
  self.wrap_reverse = {}
  self.wrap_rank = {}
  self.n_breaks = 0
  if text then
    self:wrap(text)
  end
end

--- @param text string[]
function WrappedText:wrap(text)
  local w = self.wrap_w
  local display = {}
  local wrap_forward = {}
  local wrap_reverse = {}
  local wrap_rank = {}
  local breaks = 0
  local revi = 1
  if text then
    for i, l in ipairs(text) do
      local len = string.ulen(l)
      local brk = (function()
        if len == 0 then return 0 end
        local div = math.floor(len / w)
        if math.fmod(len, w) == 0 then
          return div - 1
        else
          return div
        end
      end)()

      -- remember how many apparent lines will be overall
      local ap = brk + 1
      local fwd = {}
      for r = 1, ap do
        wrap_reverse[revi] = i
        wrap_rank[revi] = r - 1
        table.insert(fwd, revi)
        revi = revi + 1
      end
      wrap_forward[i] = fwd
      breaks = breaks + brk
      local lines = string.wrap_at(l, w)
      for _, tl in ipairs(lines) do
        table.insert(display, tl)
      end
    end
  end
  self.text = display
  self.wrap_forward = wrap_forward
  self.wrap_reverse = wrap_reverse
  self.wrap_rank = wrap_rank
  self.n_breaks = breaks
end

--- @return string[]
function WrappedText:get_text()
  return self.text
end

--- @param l integer
function WrappedText:get_line(l)
  return self.text[l]
end

--- @return integer
function WrappedText:get_text_length()
  return #(self.text) or 0
end
