--- @class EvalBase
--- @field kind string
--- @field is_lua boolean
--- @field apply function
EvalBase = {
  kind = '',
  apply = function(input)
    return input
  end,
}

--- Create a new evaluator
---@param kind string
---@param evaluator function
---@param highlight boolean
---@return EvalBase
function EvalBase:inherit(kind, evaluator, highlight)
  local e = {
    kind = kind,
    highlight = highlight,
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
