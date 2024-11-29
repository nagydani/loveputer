local class = require('util.class')

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
--- @field get_results function
--- @field move_selection function

--- @param cfg Config
Search = class.create(function(cfg)
  return {
    input = UserInputModel(cfg, nil, false, 'search'),
    searchset = {},
    resultset = {},
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
  end
end

--- @return table[]
function Search:get_results()
  return self.resultset
end

--- @param dir VerticalDir
--- @param by integer
--- @param warp boolean?
function Search:move_selection(dir, by, warp)
  local l = #(self.resultset)
  if warp then
    if dir == 'up' then
      self.selection = 1
    end
    if dir == 'down' then
      self.selection = l
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
