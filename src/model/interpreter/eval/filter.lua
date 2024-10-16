local class = require('util.class')

--- AST scope, i.e. where a validation applies
--- @class Scope

--- @alias ValidatorFilter fun(string): boolean, string|EvalError?
--- @alias AstValidatorFilter fun(AST): boolean, string|EvalError?

--- @alias TransformerFilter fun(string): string

--- @class Filters
--- @field line_validators ValidatorFilter[]
--- @field astValidators AstValidatorFilter[]
--- @field transformers TransformerFilter[]

Filters = class.create(function(v, av, tf)
  return {
    line_validators = v,
    astValidators = av,
    transformers = tf,
  }
end)

--- @param flt function|function[]
function Filters.validators_only(flt)
  local fs = {}
  if type(flt) == 'function' then
    fs = { flt }
  end
  if type(flt) == 'table' then
    for _, v in ipairs(flt) do
      if type(v) == 'function' then
        table.insert(fs, v)
      end
    end
  end
  return Filters(fs)
end
