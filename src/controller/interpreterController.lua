--- @class InterpreterController
--- @field model InterpreterModel
--- @field input InputController
---
--- @field set_eval fun(self, EvalBase)
--- @field get_eval fun(self): EvalBase
--- @field get_viewdata fun(self): ViewData
--- @field set_text fun(self, t: string|string[])
--- @field add_text fun(self, t: string|string[])
--- @field textinput fun(self, t: string)
--- @field keypressed fun(self, k: string): boolean?
--- @field clear fun(self)
--- @field get_input fun(self): InputDTO
--- @field get_text fun(self): string[]
--- @field set_custom_status fun(self, CustomStatus)
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

--- @param eval EvalBase
function InterpreterController:set_eval(eval)
  self.input:set_eval(eval)
end

--- @return EvalBase
function InterpreterController:get_eval()
  return self.input.model.evaluator
end

--- @return ViewData
function InterpreterController:get_viewdata()
  return {
    w_error = self.model:get_wrapped_error(),
  }
end

--- @param t string|string[]
function InterpreterController:set_text(t)
  self.input:set_text(t)
end

--- @param t string|string[]
function InterpreterController:add_text(t)
  self.input:add_text(t)
end

function InterpreterController:clear()
  self.input:clear()
end

--- @return InputDTO
function InterpreterController:get_input()
  return self.input:get_input()
end

--- @return string[]
function InterpreterController:get_text()
  return self:get_input().text
end

--- @param cs CustomStatus
function InterpreterController:set_custom_status(cs)
  self.input:set_custom_status(cs)
end

----------------------
--- event handlers ---
----------------------

--- @param t string
function InterpreterController:textinput(t)
  self.input:textinput(t)
end

--- @param k string
--- @return boolean?
function InterpreterController:keypressed(k)
  return self.input:keypressed(k)
end

--- @param k string
function InterpreterController:keyreleased(k)
  return self.input:keyreleased(k)
end

function InterpreterController:mousepressed(x, y, btn)
  self.input:mousepressed(x, y, btn)
end

function InterpreterController:mousereleased(x, y, btn)
  self.input:mousereleased(x, y, btn)
end

function InterpreterController:mousemoved(x, y, dx, dy)
  self.input:mousemoved(x, y, dx, dy)
end
