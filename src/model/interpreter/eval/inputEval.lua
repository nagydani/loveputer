require("model.interpreter.eval.evalBase")

--- @class InputEval: EvalBase
InputEval = {}

--- Create input evaluator
---@param highlight boolean
---@return InputEval
function InputEval:new(highlight)
  local noop = function() end
  local kind = 'input'
  if highlight then
    kind = kind .. ' lua'
  end
  --- @type InputEval
  --- @diagnostic disable-next-line -- TODO
  local ie = EvalBase:inherit(kind, noop, highlight)
  if highlight then
    local luaParser = require("model.lang.parser")('metalua')

    --- @diagnostic disable-next-line -- TODO
    ie.parser = luaParser
  end

  return ie
end
