require("model.editor.content")

local class = require('util.class')
require('util.table')
require('util.range')
require('util.string')
require('util.dequeue')

--- @alias Block Empty|Chunk
--- @alias Content Dequeue<string>|Dequeue<Block>

--- @alias Chunker fun(s: string[], s: boolean?): Dequeue<Block>
--- @alias Highlighter fun(c: str): SyntaxColoring
--- @alias Printer fun(c: string[]): string[]?


--- @param name string
--- @param content string[]
--- @param save function
--- @param chunker Chunker?
--- @param highlighter Highlighter?
--- @param printer function?
--- @return BufferModel?
local function new(name, content, save,
                   chunker, highlighter, printer)
  local _content, sel, ct
  local readonly = false

  if type(chunker) == "function" then
    ct = 'lua'
    local ok, blocks = chunker(content)
    if ok then
      local len = #blocks
      sel = len + 1
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

  return {
    name = name or 'untitled',
    content = _content,
    content_type = ct,
    save_file = save,
    chunker = chunker,
    highlighter = highlighter,
    printer = printer,
    selection = sel,
    readonly = readonly
  }
end

--- @class BufferModel
--- @field name string
--- @field content Dequeue -- Content
--- @field content_type ContentType
--- @field save_file function
--- @field selection integer
--- @field loaded integer?
--- @field readonly boolean
--- @field revmap table
---
--- @field chunker Chunker
--- @field highlighter Highlighter
--- @field printer Printer
--- @field move_selection function
--- @field get_selection function
--- @field get_selected_text function
--- @field delete_selected_text function
--- @field replace_selected_text function
--- @field render_content fun(self): string[]
BufferModel = class.create(new)

function BufferModel:save()
  return self.save_file(self:get_text_content())
end

--- @return Dequeue
function BufferModel:get_content()
  return self.content
end

--- @return string[]
function BufferModel:get_text_content()
  if self.content_type == 'lua'
  then
    return self:_render_blocks(self.content)
  elseif self.content_type == 'plain'
  then
    return self.content
  end
  return {}
end

--- @return string[]
function BufferModel:_render_blocks(blocks)
  local ret = Dequeue.typed('string')
  for _, v in ipairs(blocks) do
    if v:is_empty() then
      ret:append('')
    else
      ret:append_all(v.lines)
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
  local last = self:get_content_length() + 1
  if warp then
    if dir == 'up' then
      self.selection = 1
      return true
    end
    if dir == 'down' then
      self.selection = last
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
    if (cur + by) <= last then
      self.selection = cur + by
      return true
    end
  end
  return false
end

--- @return integer
function BufferModel:get_selection()
  return self.selection
end

--- @private
--- @return Block?
function BufferModel:_get_selected_block()
  if self.content_type == 'plain' then return end

  local sel = self.selection
  if sel == self:get_content_length() + 1 then
    local ln = self.content:last().pos.fin + 1
    return Empty(ln)
  end
  return self.content[sel]
end

--- @return integer
function BufferModel:get_selection_start_line()
  if self.content_type == 'lua' then
    local b = self:_get_selected_block()
    if b then
      local ln = b.pos.start
      return ln
    end
  end
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
  if self.content_type == 'lua' then
    local sb = self.content[sel]
    if not sb then return end

    local l = sb.pos:len()
    self.content:remove(sel)
    for i = sel, self:get_content_length() do
      local b = self.content[i]
      local r = b.pos
      b.pos = r:translate(-l)
    end
  else
    self.content:remove(sel)
  end
end

--- @param t string[]|Block[]
--- @return boolean insert
--- @return integer? inserted_lines
function BufferModel:replace_selected_text(t)
  if self.content_type == 'lua' then
    local chunks = t
    local n = #chunks
    if n == 0 then
      return false
    end
    local sel = self.selection
    --- content start and original length
    local cs, ol = (function()
      local current = self.content[sel]
      if current then
        return current.pos.start, self.content[sel].pos:len()
      end
      local last = self.content:last()
      if last then
        return self.content:last().pos.fin + 1, 0
      else --- empty file
        return 1, 0
      end
    end)()

    if n == 1 then
      local c = chunks[1]
      local nr = c.pos:translate(cs - 1)
      c.pos = nr
      self.content[sel] = chunks[1]
    else
      --- remove old chunk
      self.content:remove(sel)
      --- insert new version of the chunk(s)
      for i = #chunks, 1, -1 do
        local c = chunks[i]
        local nr = c.pos:translate(cs - 1)
        c.pos = nr
        self.content:insert(c, sel)
      end
    end
    --- move subsequent chunks down
    local diff = chunks[n].pos:len() - ol
    if diff ~= 0 then
      for i = sel + 1, self:get_content_length() do
        local b = self.content[i]
        b.pos = b.pos:translate(diff)
      end
    end

    return true, n
  else
    local sel = self.selection
    local clen = #(self.content)
    local ti = sel
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
    return false
  end
end

--- @param i integer?
function BufferModel:set_loaded(i)
  local n = i or self:get_selection()
  self.loaded = n
end

function BufferModel:clear_loaded()
  self.loaded = nil
end

function BufferModel:loaded_is_sel()
  if not self.loaded then
    --- only check if there is in fact something to compare to
    return true
  end
  return self.loaded == self.selection
end

function BufferModel:select_loaded()
  local l = self.loaded
  if l then
    self.selection = l
  end
end

--- Insert a new line or empty block _before_ the selection
--- @param i integer
function BufferModel:insert_newline(i)
  --- block or line number
  local bln = i or self:get_selection()
  if self.content_type == 'lua' then
    local sb = self.content[bln]
    if not sb then return end
    local prev_b = self.content[bln - 1]
    -- disallow consecutive empties
    local prev_empty = prev_b and prev_b:is_empty()
    local sel_empty = sb:is_empty()
    local cons = prev_empty or sel_empty
    if cons then return end

    local ln = self:get_selection_start_line()
    self.content:insert(Empty(ln), bln)
    for j = bln + 1, self:get_content_length() do
      local b = self.content[j]
      local r = b.pos
      b.pos = r:translate(1)
    end
  else
    self.content:insert('', bln)
  end
end
