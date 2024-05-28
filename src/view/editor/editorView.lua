require("view.editor.bufferView")

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

--- @param cfg ViewConfig
--- @param ctrl EditorController
function EditorView.new(cfg, ctrl)
  local self = setmetatable({
    cfg = cfg,
    controller = ctrl,
    input = InputView.new(cfg, ctrl.input),
    buffer = BufferView(cfg, ctrl:get_active_buffer())
  }, EditorView)
  return self
end

function EditorView:draw()
  local G = love.graphics

  -- local M = self.controller.model
  -- local content = M.buffer:get_content()
  -- local text = string.join(content, '\n')

  -- G.print(text)


  local IC = self.controller.input
  self.input:draw(IC:get_input())
end
