require("model.interpreter.eval.evalBase")

--- @class InputEval: EvalBase
InputEval = {}

--- Create input evaluator
---@param highlight boolean
---@return InputEval
function InputEval:new(highlight)
  local noop = function() end
  --- @type InputEval
  --- @diagnostic disable-next-line -- TODO
  local ie = EvalBase:inherit('input', noop, highlight)
  if highlight then
    local luaParser = require("model.lang.parser")('metalua')

    --- @diagnostic disable-next-line -- TODO
    ie.parser = luaParser
  end

  return ie
end
