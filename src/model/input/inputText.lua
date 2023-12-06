require("model.input.cursor")
require("util.dequeue")


--- @class InputText : Dequeue table
--- @field new function
--- @field traverse function
InputText = {}

function InputText:new(values)
  local text = Dequeue:new(values)
  if not values or values == '' then
    text:append('')
  end

  setmetatable(self, Dequeue)
  setmetatable(text, self)
  self.__index = self

  return text
end

--- Traverses text between two cursor positions
--- from and to are required to be in order at this point
---@param from    Cursor
---@param to      Cursor
---@param options table
---@return table  traversed
function InputText:traverse(from, to, options)
  local ls = from.l
  local le = to.l
  -- cursor position is +1 off
  local cs = from.c
  local ce = to.c - 1
  local lines = string.lines(self)

  local ret = Dequeue:new()
  local defaults = {
    delete = false,
  }
  local opts = (function()
    if not options then
      return defaults
    else
      return {
        delete = options.delete,
      }
    end
  end)()

  if ls == le then
    if ce > cs then
      local l = lines[ls]
      local pre, mid, post = string.splice(l, cs - 1, ce)
      ret:append(mid)
      if opts.delete then
        self:update(pre .. post, ls)
      end
    else
      ret:append('')
    end
  else
    local l1 = lines[ls]
    local ll = lines[le]
    local fls, fle = string.split_at(l1, cs)
    ret:append(fle)
    -- intermediate lines
    for i = ls + 1, le - 1 do
      ret:append(lines[i])
    end
    -- last line
    local lls, lle = string.split_at(ll, ce + 1)
    ret:append(lls)
    if opts.delete then
      self:update(fls .. lle, ls)
      for i = le, ls + 1, -1 do
        self:remove(i)
      end
    end
  end

  return ret
end
