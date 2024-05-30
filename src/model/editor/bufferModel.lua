require('util.table')

--- @alias Content Dequeue
--- @alias Selected integer[]

--- @class BufferModel
--- @field name string
--- @field content Content
--- @field selection Selected
---
--- @field move_highlight function
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
  buffer:push_back('EOF')
  local self = setmetatable({
    name = name or 'untitled',
    content = buffer,
    selection = { #buffer },
  }, BufferModel)

  return self
end

--- @return string[]?
function BufferModel:get_content()
  return self.content or {}
end

--- @param dir VerticalDir
function BufferModel:move_highlight(dir)
  -- TODO chunk selection
  local cur = self.selection[1]
  if dir == 'up' then
    if cur > 1 then
      self.selection[1] = cur - 1
    end
  end
  if dir == 'down' then
    if cur < #(self.content) then
      self.selection[1] = cur + 1
    end
  end
end

--- @return Selected
function BufferModel:get_selection()
  return self.selection
end

--- @return string[]
function BufferModel:get_selected_text()
  local sel = self.selection
  local si = sel[1]
  local ei = sel[#sel]
  return table.slice(self.content, si, ei)
end
