local class = require('util.class')
require('view.editor.search.resultsView')

--- @param cfg ViewConfig
--- @param ctrl SearchController
local function new(cfg, ctrl)
  return {
    input = UserInputView(cfg, ctrl.input)
  }
end

--- @class SearchView
--- @field controller SearchController
--- @field input UserInputView
SearchView = class.create(new)

--- @param input InputDTO
function SearchView:draw(input)
  self.input:draw(input)
end
