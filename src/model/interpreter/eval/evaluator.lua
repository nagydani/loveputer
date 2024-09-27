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
      if parser then
        local ok, result = parser.parse(s)
        if not ok then
          table.insert(errors, result)
          return false, errors
        else
          local ast = result
          return true, ast
        end
      end
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
--- @param custom_apply function?
function Evaluator.plain(label, filters, custom_apply)
  return Evaluator.new(label, nil, filters, custom_apply)
end

TextEval = Evaluator.plain('text')

local luaParser = require("model.lang.parser")()

--- @param label string?
--- @param filters Filters?
--- @param custom_apply function?
LuaEval = function(label, filters, custom_apply)
  local l = label or 'lua'
  return Evaluator(l, luaParser, filters, custom_apply)
end

InputEvalText = Evaluator.plain('text input')
InputEvalLua = Evaluator('lua input', luaParser)

ValidatedTextEval = function(filter)
  local ft = Filters.validators_only(filter)
  return Evaluator.plain('plain', ft)
end

LuaEditorEval = (function()
  --- AST validations
  local test = function(ast)
    -- Log.info('AST', Debug.terse_ast(ast, true, 'lua'))
    -- return false, EvalError('test', 1, 1)
    return true
  end

  --- text validations
  local max_length = function(n)
    return function(s)
      if string.len(s) < n then
        return true
      end
      return false, 'line too long!'
    end
  end
  local line_length = max_length(64)

  local ft = {
    validators = { line_length },
    astValidators = { test },
  }
  return LuaEval(nil, ft)
end)()
