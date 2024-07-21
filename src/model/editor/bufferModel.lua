require("model.editor.content")
require("model.interpreter.eval.luaEval")

require('util.table')
require('util.range')
require('util.string')
require('util.dequeue')

--- @alias Block Empty|Chunk
--- @alias Content Dequeue<string>|Dequeue<Block>
--- @alias Selected integer

--- @alias Chunker fun(s: string[], s: boolean?): Dequeue<Block>
--- @alias Highlighter fun(c: string[]): SyntaxColoring

--- @class BufferModel
--- @field name string
--- @field content Dequeue -- Content
--- @field content_type ContentType
--- @field chunker Chunker
--- @field highlighter Highlighter
--- @field selection Selected
--- @field readonly boolean
--- @field revmap table
---
--- @field move_selection function
--- @field get_selection function
--- @field get_selected_text function
--- @field delete_selected_text function
--- @field replace_selected_text function
BufferModel = {}
BufferModel.__index = BufferModel

setmetatable(BufferModel, {
  __call = function(cls, ...)
    return cls.new(...)
  end,
})

--- @param name string
--- @param content string[]
--- @param chunker Chunker
--- @param highlighter Highlighter
--- @return BufferModel?
function BufferModel.new(name, content, chunker, highlighter)
  local _content, sel, ct
  local readonly = false

  if type(chunker) == "function" then
    ct = 'lua'
    local ok, blocks = chunker(content)
    if ok then
      local len = #blocks
      sel = len
    else
      readonly = true
      sel = 1
    end
    _content = blocks
  else
    ct = 'plain'
    _content = Dequeue(content, 'string')
    sel = #_content + 1
  end

  local self = setmetatable({
    name = name or 'untitled',
    content = _content,
    content_type = ct,
    chunker = chunker,
    highlighter = highlighter,
    selection = sel,
    readonly = readonly
  }, BufferModel)

  return self
end

--- @return Dequeue
function BufferModel:get_content()
  return self.content
end

--- @return string[]
function BufferModel:get_text_content()
  if self.content_type == 'lua'
  then
    return self:render_blocks(self.content)
  elseif self.content_type == 'plain'
  then
    return self.content
  end
  return {}
end

--- @return string[]
function BufferModel:render_blocks(blocks)
  local ret = Dequeue.typed('string')
  for _, v in ipairs(blocks) do
    if v.tag == 'chunk' then
      ret:append_all(v.lines)
    elseif v.tag == 'empty' then
      ret:append('')
    end
  end
  return ret
end

--- @return integer
function BufferModel:get_content_length()
  return #(self.content) or 0
end

--- @param dir VerticalDir
--- @param by integer
--- @param warp boolean?
--- @return boolean moved
function BufferModel:move_selection(dir, by, warp)
  local of = (function()
    if self.content_type == 'plain' then
      return 1
    else
      return 0
    end
  end)()
  if warp then
    if dir == 'up' then
      self.selection = 1
      return true
    end
    if dir == 'down' then
      self.selection = self:get_content_length() + of
      return true
    end
    return false
  end

  local cur = self.selection
  local by = by or 1
  if dir == 'up' then
    if (cur - by) >= 1 then
      self.selection = cur - by
      return true
    end
  end
  if dir == 'down' then
    if (cur + by) <= self:get_content_length() + of then
      self.selection = cur + by
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
  if self.content_type == 'lua' then
    --- @type Block
    local s = self.content[sel]
    if table.is_instance(s, 'chunk') then
      return table.clone(s.lines)
    else
      return {}
    end
  else
    return self.content[sel] or {}
  end
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
--- @return integer?
function BufferModel:replace_selected_text(t)
  local sel = self.selection
  local clen = #(self.content)
  if #sel == 1 then
    local ti = sel[1]
    if #t == 1 then
      self.content[ti] = t[1]
      if ti > clen then
        return true, 1
      end
    else
      self.content:remove(ti)
      for i = #t, 1, -1 do
        self.content:insert(t[i], ti)
      end
      return true, #t
    end
  else
    -- TODO multiine
  end
  return false
end
