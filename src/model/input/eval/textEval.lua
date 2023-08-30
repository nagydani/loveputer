require("model.input.eval.eval")

TextEval = {}

function TextEval:new()
  local te = Eval:inherit('text')

  return te
end
