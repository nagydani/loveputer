require("model.input.eval.evalBase")

InputEval = {}

--- Create input evaluator
---@param highlight boolean
---@return table
function InputEval:new(highlight)
  local apply = function() end
  local ie = EvalBase:inherit('input', apply, highlight)
  if highlight then
    local luaParser = require("model.parser")('metalua')

    ie.parser = luaParser
  end

  return ie
end
