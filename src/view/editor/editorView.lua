require("view.input.interpreterView")
require("view.input.userInputView")
require("view.editor.bufferView")

require("util.string")

--- @class EditorView
--- @field cfg ViewConfig
--- @field controller EditorController
--- @field input UserInputView
--- @field buffer BufferView
EditorView = {}
EditorView.__index = EditorView

setmetatable(EditorView, {
  __call = function(cls, ...)
    return cls.new(...)
  end,
})

--- @param cfg ViewConfig
--- @param ctrl EditorController
function EditorView.new(cfg, ctrl)
  local self = setmetatable({
    cfg = cfg,
    controller = ctrl,
    input = UserInputView(cfg, ctrl.input),
    buffer = BufferView(cfg),
  }, EditorView)
  ctrl.view = self
  return self
end

function EditorView:draw()
  local ctrl = self.controller
  self.buffer:draw(ctrl:get_active_buffer())

  local input = self.controller:get_input()
  self.input:draw(input)
end

function EditorView:refresh()
  self.buffer:refresh()
end
