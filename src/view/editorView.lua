require("util.string")

--- @class EditorView
--- @field controller EditorController
--- @field input InputView
EditorView = {}
EditorView.__index = EditorView

setmetatable(EditorView, {
  __call = function(cls, ...)
    return cls.new(...)
  end,
})

--- @param cfg Config
--- @param ctrl EditorController
function EditorView.new(cfg, ctrl)
  local self = setmetatable({
    cfg = cfg,
    controller = ctrl,
    input = InputView.new(cfg, ctrl.input),
  }, EditorView)
  return self
end

function EditorView:draw()
  local IC = self.controller.input
  self.input:draw(IC:get_input())
end
