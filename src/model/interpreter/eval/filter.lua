--- AST scope, i.e. where a validation applies
--- @class Scope

--- @alias error {msg: string, pos: Cursor}
--- @alias ValidatorFilter fun(string): boolean, error
--- @alias AstValidatorFilter fun(AST, Scope): boolean, error

--- @alias TransformerFilter fun(string): string

--- @class Filters
--- @field validators ValidatorFilter[]
--- @field astValidators AstValidatorFilter[]
--- @field transformers TransformerFilter[]

Filters = class.create(function(v, av, tf)
  return {
    validators = v,
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
