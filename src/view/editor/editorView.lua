require("view.input.interpreterView")
require("view.input.userInputView")
require("view.editor.bufferView")

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
  }
  --- hook the view in the controller
  ctrl.view = ev
  return ev
end

--- @class EditorView
--- @field cfg ViewConfig
--- @field controller EditorController
--- @field input UserInputView
--- @field buffer BufferView
EditorView = class.create(new)

function EditorView:draw()
  local ctrl = self.controller
  self.buffer:draw(ctrl:get_active_buffer())

  local input = self.controller:get_input()
  self.input:draw(input)
end

function EditorView:refresh()
  self.buffer:refresh()
end
