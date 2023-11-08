EvalBase = {
  kind = '',
  apply = function(input)
    return input
  end
}


function EvalBase:inherit(kind, evaluator)
  local e = {
    kind = kind
  }
  setmetatable(e, self)
  self.__index = self

  if type(evaluator) == 'function' then
    e.eval = evaluator
  else
    e.eval = function() end
  end
  e.apply = function(...)
    local args = { ... }
    return pcall(e.eval, args)
  end

  return e
end
