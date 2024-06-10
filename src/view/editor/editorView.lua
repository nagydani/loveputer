require("view.input.inputView")
require("view.editor.bufferView")

require("util.string")

--- @class EditorView
--- @field controller EditorController
--- @field input InputView
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
    input = InputView.new(cfg, ctrl.input),
    buffer = BufferView(cfg)
  }, EditorView)
  ctrl.view = self
  return self
end

function EditorView:draw()
  local ctrl = self.controller
  self.buffer:draw(ctrl:get_active_buffer())

  local IC = self.controller.input
  self.input:draw(IC:get_input())
end

function EditorView:refresh()
  self.buffer:refresh()
end
