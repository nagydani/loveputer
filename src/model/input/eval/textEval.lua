require("model.input.eval.evalBase")

TextEval = {}

function TextEval:new()
  local ret = function(i) return i end
  local te = EvalBase:inherit('text', ret)

  return te
end
