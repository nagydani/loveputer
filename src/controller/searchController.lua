local class = require('util.class')

local function new(uic)
  return {
    input = uic,
  }
end

--- @class SearchController
--- @field input UserInputController
SearchController = class.create(new)

--- @param k string
function SearchController:keypressed(k)
end

--- @return InputDTO
function SearchController:get_input()
  return self.input:get_input()
end
