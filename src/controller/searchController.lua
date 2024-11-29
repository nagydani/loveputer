local class = require('util.class')

--- @param model Search
--- @param uic UserInputController
local function new(model, uic)
  return {
    model = model,
    input = uic,
  }
end

--- @class SearchController
--- @field model Search
--- @field input UserInputController
SearchController = class.create(new)

--- @param items table[]
function SearchController:load(items)
  self.model:load(items)
end

--- @return ResultsDTO
function SearchController:get_results()
  local res = self.model:get_results()
  return {
    results = res,
    selection = self.model.selection,
  }
end

--- @return InputDTO
function SearchController:get_input()
  return self.input:get_input()
end

function SearchController:clear()
  self.model.input:clear_input()
  self.model:clear()
end

function SearchController:update_results()
  local kws = self.input:get_text()[1]
  self.model:narrow(kws)
end

---------------------------
---  keyboard handlers  ---
---------------------------

--- @private
--- @param dir VerticalDir
--- @param by integer?
--- @param warp boolean?
function SearchController:_move_sel(dir, by, warp)
  self.model:move_selection(dir, by, warp)
end

--- @param k string
--- @return integer? jump
function SearchController:keypressed(k)
  local function navigate()
    -- move selection
    if k == "up" then
      self:_move_sel('up')
    end
    if k == "down" then
      self:_move_sel('down')
    end
    if k == "home" then
      self:_move_sel('up', nil, true)
    end
    if k == "end" then
      self:_move_sel('down', nil, true)
    end

  end
  local function removers()
    local input = self.model.input
    if k == "backspace" then
      input:backspace()
      self:update_results()
    end
    if k == "delete" then
      input:delete()
      self:update_results()
    end
  end

  navigate()
  removers()
  if Key.is_enter(k) then
    local sel = self.model.selection
    local r = self.model.resultset[sel].r
    local ln = r.line
    return ln
  end
end

--- @param t string
function SearchController:textinput(t)
  self.input:add_text(t)
  self:update_results()
end
