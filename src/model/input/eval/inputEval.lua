require("model.input.eval.evalBase")

InputEval = {}

function InputEval:new()
  local apply = function() end
  local ie = EvalBase:inherit('input', apply)

  return ie
end
