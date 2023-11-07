require("model.input.eval.evalBase")

TextEval = {}

function TextEval:new()
  local te = EvalBase:inherit('text')

  return te
end
