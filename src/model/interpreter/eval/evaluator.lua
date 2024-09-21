local class = require('util.class')

--- @class Evaluator
--- @field label string
--- @field parser Parser?
--- @field validators ValidatorFilter[]
--- @field astValidators AstValidatorFilter[]
--- @field transformers TransformerFilter[]
Evaluator = class.create()

--- @param label string
--- @param parser Parser?
function Evaluator.new(label, parser, filters)
  local f = filters or {}
  local self = setmetatable({
    label         = label,
    parser        = parser,
    validators    = f.validators or {},
    astValidators = f.astValidators or {},
    transformers  = f.transformers or {},
  }, Evaluator)

  self.apply = function(s)
    return true, s
  end

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
