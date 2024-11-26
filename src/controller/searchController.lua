local class = require('util.class')

local function new(uic)
  return {
    input = uic,
  }
end

--- @class SearchController
--- @field input UserInputController
SearchController = class.create(new)

--- @return InputDTO
function SearchController:get_input()
  return self.input:get_input()
end

---------------------------
---  keyboard handlers  ---
---------------------------

--- @param k string
function SearchController:keypressed(k)
end

--- @param t string
function SearchController:textinput(t)
  self.input:add_text(t)
end
