require("model.interpreter.eval.evalBase")

local class = require('util.class')
require("util.string")
require("util.debug")

--- @class LuaEval: EvalBase
--- @field parser table
LuaEval = class.create()

--- Create a new evaluator
---@param parser string?
---@return LuaEval
function LuaEval.new(parser)
  local luaParser = require("model.lang.parser")(
    parser or 'metalua'
  )

  return {
    kind = 'lua',
    parser = luaParser,
    apply = luaParser.parse,
    is_lua = true,
    highlight = true,
  }
end
