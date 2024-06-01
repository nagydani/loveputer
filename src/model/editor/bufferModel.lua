require('util.table')

--- @alias Content Dequeue
--- @alias Selected integer[]

--- @class BufferModel
--- @field name string
--- @field content Content
--- @field selection Selected
---
--- @field move_selection function
BufferModel = {}
BufferModel.__index = BufferModel

setmetatable(BufferModel, {
  __call = function(cls, ...)
    return cls.new(...)
  end,
})

--- @param name string
--- @param content string[]?
function BufferModel.new(name, content)
  local buffer = Dequeue(content)
  local self = setmetatable({
    name = name or 'untitled',
    content = buffer,
    selection = { #buffer + 1 },
  }, BufferModel)

  return self
end

--- @return string[]
function BufferModel:get_content()
  return self.content or {}
end

--- @return integer
function BufferModel:get_content_length()
  return #(self.content) or 0
end

--- @param dir VerticalDir
--- @return boolean moved
function BufferModel:move_selection(dir)
  -- TODO chunk selection
  local cur = self.selection[1]
  if dir == 'up' then
    if cur > 1 then
      self.selection[1] = cur - 1
      return true
    end
  end
  if dir == 'down' then
    if cur <= #(self.content) then
      self.selection[1] = cur + 1
      return true
    end
  end
  return false
end

--- @return Selected
function BufferModel:get_selection()
  return self.selection
end

--- @return string[]
function BufferModel:get_selected_text()
  local sel = self.selection
  -- continuous selection assumed
  local si = sel[1]
  local ei = sel[#sel]
  return table.slice(self.content, si, ei)
end

function BufferModel:delete_selected_text()
  local sel = self.selection
  -- continuous selection assumed
  for i = #sel, 1, -1 do
    self.content:remove(sel[i])
  end
end

--- @param t string[]
--- @return boolean insert
function BufferModel:replace_selected_text(t)
  local sel = self.selection
  local clen = #(self.content)
  if #sel == 1 then
    if #t == 1 then
      local ti = sel[1]
      self.content[ti] = t[1]
      if ti > clen then
        return true
      end
    end
  else
    -- TODO multiine
  end
  return false
  -- -- continuous selection assumed
  -- for i = #sel, 1, -1 do
  --   self.content:remove(sel[i])
  -- end
end
