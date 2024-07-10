--- @class InterpreterController
--- @field model InterpreterModel
--- @field input InputController
InterpreterController = {}
InterpreterController.__index = InterpreterController

setmetatable(InterpreterController, {
  __call = function(cls, ...)
    return cls.new(...)
  end,
})

--- @param model InterpreterModel
--- @param input InputController
function InterpreterController.new(model, input)
  local self = setmetatable({
    model = model,
    input = input,
  }, InterpreterController)

  return self
end

--- @return ViewData
function InterpreterController:get_viewdata()
  return {
    w_error = self.model:get_wrapped_error(),
  }
end
