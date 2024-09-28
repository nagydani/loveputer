require("view.input.statusline")
require("util.debug")
require("util.view")

--- @class InputView
--- @field cfg ViewConfig
--- @field controller InputController
--- @field statusline table
--- @field oneshot boolean
--- @field draw function
InputView = {}
InputView.__index = InputView

setmetatable(InputView, {
  __call = function(cls, ...)
    return cls.new(...)
  end,
})

--- @param cfg ViewConfig
--- @param ctrl InputController
function InputView.new(cfg, ctrl)
  local self = setmetatable({
    cfg = cfg,
    controller = ctrl,
    statusline = Statusline:new(cfg),
    oneshot = ctrl.model.oneshot,
  }
  , InputView)

  return self
end

--- @param input InputDTO
--- @param time number
function InputView:draw(input, time)
  ---@diagnostic disable-next-line: param-type-mismatch
  UserInputView.draw_input(self, input, time)
end
