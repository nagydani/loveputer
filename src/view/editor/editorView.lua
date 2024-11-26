require("view.input.interpreterView")
require("view.input.userInputView")
require("view.editor.bufferView")
require("view.editor.search.searchView")

require("util.string")
local class = require('util.class')

--- @param cfg ViewConfig
--- @param ctrl EditorController
local function new(cfg, ctrl)
  local ev = {
    cfg = cfg,
    controller = ctrl,
    input = UserInputView(cfg, ctrl.input),
    buffer = BufferView(cfg),
    search = SearchView(cfg, ctrl.search),
  }
  --- hook the view in the controller
  ctrl.view = ev
  return ev
end

--- @class EditorView : ViewBase
--- @field controller EditorController
--- @field input UserInputView
--- @field buffer BufferView
--- @field search SearchView
EditorView = class.create(new)

function EditorView:draw()
  local ctrl = self.controller
  local mode = ctrl:get_mode()
  if mode == 'search' then
    self.search:draw(ctrl.search:get_input())
  else
    local spec = mode == 'reorder'
    self.buffer:draw(spec)
    local input = ctrl:get_input()
    self.input:draw(input)
  end
end

--- @param moved integer?
function EditorView:refresh(moved)
  self.buffer:refresh(moved)
end
