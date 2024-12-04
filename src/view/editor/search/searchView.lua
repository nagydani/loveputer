local class = require('util.class')
require('view.editor.search.resultsView')
require("view.input.userInputView")

--- @param cfg ViewConfig
--- @param ctrl SearchController
local function new(cfg, ctrl)
  return {
    controller = ctrl,
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
  local ctrl = self.controller
  local rs = ctrl:get_results()
  self.results:draw(rs)
  if ViewUtils.conditional_draw('show_input') then
    self.input:draw(input)
  end
end
