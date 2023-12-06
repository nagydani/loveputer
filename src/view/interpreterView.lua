require("view.inputView")

InterpreterView = {}

function InterpreterView:new(cfg, ctrl)
  local iv = {
    cfg = cfg,
    controller = ctrl,
    input = InputView:new(cfg, ctrl),
  }
  setmetatable(iv, self)
  self.__index = self

  return iv
end

function InterpreterView:draw(input)
  self.input:draw(input)
end
