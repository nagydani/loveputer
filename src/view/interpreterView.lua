require("view.inputView")

--- @class InterpreterView
--- @field cfg Config
--- @field controller ConsoleController
--- @field input InputView
InterpreterView = {}

function InterpreterView:new(cfg, ctrl)
  local iv = {
    cfg = cfg,
    controller = ctrl,
    input = InputView:new(cfg, ctrl.input),
  }
  setmetatable(iv, self)
  self.__index = self

  return iv
end

function InterpreterView:draw(input)
  self.input:draw(input)
end
