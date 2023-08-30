Eval = {
  kind = '',
  apply = function(input)
    return input
  end
}


function Eval:inherit(kind, evaluator)
  local e = {
    kind = kind
  }
  setmetatable(e, self)
  self.__index = self

  if type(evaluator) == 'function' then
    e.apply = evaluator
  end

  return e
end
