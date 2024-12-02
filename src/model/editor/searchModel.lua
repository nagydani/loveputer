local class = require('util.class')
require('util.table')
require('util.scrollableContent')

--- @alias itemid integer

--- @class Result
--- @field id itemid
--- @field preview string
--- @field text string

--- @class Search
--- @field input UserInputModel
--- @field searchset { [itemid]: table }
--- @field resultset table[]
--- @field selection integer?
---
--- @field load function
--- @field clear function
--- @field get_results function
--- @field move_selection function
--- @field get_selection function
--- @field narrow function
--- @field scroll function
--- @field follow_selection function

--- @param cfg Config
Search = class.create(function(cfg)
  local l = cfg.view.lines
  return {
    input = UserInputModel(cfg, nil, false, 'search'),
    searchset = {},
    resultset = {},
    visible = ScrollableContent(0, 1, l)
  }
end)

--- @param items table[]
function Search:load(items)
  if #items > 0 then
    self.searchset = table.clone(items)
    for i, v in ipairs(self.searchset) do
      if v then
        table.insert(self.resultset, {
          idx = i,
          r = self.searchset[i],
        })
      end
    end
    self.selection = 1
    self.visible:update(#items)
  end
end

function Search:clear()
  self.searchset = {}
  self.resultset = {}
  self.selection = 1
end

--- @return table[]
function Search:get_results()
  local rs = self.resultset
  return self.visible:get_visible(rs)
end

--- @param dir VerticalDir
--- @param by integer
--- @param warp boolean?
function Search:move_selection(dir, by, warp)
  local l = #(self.resultset)
  if warp then
    if dir == 'up' then
      self.selection = 1
      return true
    end
    if dir == 'down' then
      self.selection = l
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
    if (cur + by) <= l then
      self.selection = cur + by
      return true
    end
  end
  return false
end

--- @param visible boolean
--- @return integer
function Search:get_selection(visible)
  local s = self.selection
  if visible then
    s = s - self.visible.offset
  end
  return s
end

--- @param input string
function Search:narrow(input)
  local csel = self.selection
  local selected = self.resultset[csel]
  self.resultset = nil
  local res = {}
  local filter = string.ulen(input) > 0

  local function match(val)
    local kw
    if string.is_lower(input) then
      kw = string.lower(val)
    else
      kw = val
    end
    return string.matches(kw, input)
  end

  for i, v in ipairs(self.searchset) do
    if not filter
        or match(v.name)
    then
      table.insert(res, {
        idx = i,
        r = v,
      })
    end
  end
  self.resultset = res
  self.visible:update(#res)

  --- update selection
  if selected then
    local prev = function(r)
      return r.idx == selected.idx
    end
    local newsel = table.find_by(res, prev)
    if newsel then
      self.selection = newsel
    else
      local rl = #(self.resultset)
      if csel > rl and rl > 0 then
        self.selection = rl
      end
    end
  else
    self.selection = 1
  end
end

--- @param dir VerticalDir
--- @param by integer?
--- @param warp boolean?
function Search:scroll(dir, by, warp)
  self.visible:scroll(dir, by, warp)
end

function Search:follow_selection()
  local v, dir, d = self:is_selection_visible()
  if not v then
    if dir and d then self:scroll(dir, d) end
  end
end

--- @return boolean
--- @return VerticalDir?
--- @return number? diff
function Search:is_selection_visible()
  local sel = self.selection

  local r = self.visible:get_range()
  if r:inc(sel) then return true end

  local dir = (function()
    if r.start > sel then return 'up' end
    if r.fin < sel then return 'down' end
  end)()
  local d = (function()
    if dir == 'up' then
      return r.start - sel
    elseif dir == 'down' then
      local off = self.visible.size_max - 1
      return sel - r.fin + off
    end
  end)()

  return false, dir, d
end
