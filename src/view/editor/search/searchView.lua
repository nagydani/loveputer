local class = require('util.class')
require('view.editor.search.resultsView')
require("view.input.userInputView")

--- @param cfg ViewConfig
--- @param ctrl SearchController
local function new(cfg, ctrl)
  return {
    results = ResultsView(cfg),
    input = UserInputView(cfg, ctrl.input)
  }
end

--- @class SearchView
--- @field controller SearchController
--- @field results ResultsView
--- @field input UserInputView
SearchView = class.create(new)

--- @param input InputDTO
function SearchView:draw(input)
  self.results:draw()
  self.input:draw(input)
end
