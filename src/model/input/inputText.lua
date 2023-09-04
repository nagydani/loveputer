require("model.input.cursor")
require("util.dequeue")

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
  local cs = from.c
  local ce = to.c
  local lines = string.lines(self)
  local till = le + 1 - ls

  local ret = Dequeue:new()
  local defaults = {
    slow = false,
    delete = false,
  }
  local opts = (function()
    if not options then
      return defaults
    else
      return {
        slow = options.slow,
        delete = options.delete,
      }
    end
  end)()

  if ls == le then
    if ce > cs then
      ret:append(string.usub(lines[ls], cs, ce))
    else
      ret:append('')
    end
  else
    local l1 = lines[ls]
    local ll = lines[le]
    if opts.slow then
      -- first line
      local _l1 = ''
      for i = cs, string.ulen(l1) do
        _l1 = _l1 .. string.usub(l1, i, i)
      end
      ret:append(_l1)
      -- intermediate lines
      for i = 2, till - 1 do
        local l = lines[i]
        local e = string.ulen(l)
        local _l = ''
        for j = 1, e do
          _l = _l .. string.usub(l, j, j)
        end
        ret:append(_l)
      end
      -- last line
      local _ll = ''
      for i = 1, ce do
        _ll = _ll .. string.usub(ll, i, i)
      end
      ret:append(_ll)
    else
      -- first line
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
        self[ls] = fls
        self[le] = lle
        for i = ls + 1, le - 1 do
          self:remove(i)
        end
      end
    end
  end

  return ret
end
