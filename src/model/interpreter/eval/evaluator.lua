require('model.interpreter.eval.filter')

local class = require('util.class')

--- @class Evaluator
--- @field label string
--- @field parser Parser?
--- @field apply function
--- @field validators ValidatorFilter[]
--- @field astValidators AstValidatorFilter[]
--- @field transformers TransformerFilter[]
Evaluator = class.create()

--- @param label string
--- @param parser Parser?
--- @param filters Filters?
--- @param custom_apply function?
function Evaluator.new(label, parser, filters, custom_apply)
  local f = filters or {}
  local self = setmetatable({
    label         = label,
    parser        = parser,
    validators    = f.validators or {},
    astValidators = f.astValidators or {},
    transformers  = f.transformers or {},
  }, Evaluator)

  local default_apply = function(s)
    local errors = {}
    local valid = true
    --- TODO: string[] handling
    local str = s
    if type(s) == "table" then
      str = string.unlines(s)
    end

    --- run validations
    for _, fv in ipairs(self.validators) do
      local ok, verr = fv(str)
      if not ok then
        valid = false
        local e = EvalError.wrap(verr)
        table.insert(errors, e)
      end
    end
    if valid then
      return true, s
    else
      return false, errors
    end
  end
  self.apply = custom_apply or default_apply

  return self
end

--- @param label string
--- @param filters Filters?
function Evaluator.plain(label, filters)
  return Evaluator.new(label, nil, filters)
end

--- @param label string
--- @param parser Parser
--- @param filters Filters?
function Evaluator.structured(label, parser, filters)
  return Evaluator.new(
    label, parser, filters)
end

TextEval = Evaluator.plain('text')

local luaParser = require("model.lang.parser")()
LuaEval = Evaluator.structured('lua', luaParser)

InputEvalText = Evaluator.plain('text input')
InputEvalLua = Evaluator.structured('lua input', luaParser)

ValidatedTextEval = function(filter)
  local ft = Filters.validators_only(filter)
  return Evaluator.plain('plain', ft)
end
  local ft = {
    validators = fs
  }
  return Evaluator.plain('plain', ft)
end
