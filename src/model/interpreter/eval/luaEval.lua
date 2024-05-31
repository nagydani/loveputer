require("model.interpreter.eval.evalBase")

require("util.string")
require("util.debug")

--- @class LuaEval: EvalBase
--- @field parser table
LuaEval = {}
LuaEval.__index = LuaEval

--- Create a new evaluator
---@param parser string
---@return LuaEval
function LuaEval:new(parser)
  local luaParser = require("model.lang.parser")(parser)
  local eval = function(args)
    return luaParser.parse(args[1])
  end

  --- @type LuaEval
  --- @diagnostic disable-next-line -- TODO
  local ev = EvalBase:inherit('lua', eval, true)
  ev.parser = luaParser
  ev.is_lua = true

  return ev
end
