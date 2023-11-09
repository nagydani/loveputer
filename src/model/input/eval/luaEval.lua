require("model.input.eval.evalBase")

require("util.string")
require("util.debug")

LuaEval = {}

--- Create a new evaluator
---@param parser string
---@return table
function LuaEval:new(parser)
  local luaParser = require("model.parser")(parser)
  local eval = function(args)
    return luaParser.parse(args[1])
  end

  local ev = EvalBase:inherit('lua', eval, true)
  ev.parser = luaParser
  ev.is_lua = true

  return ev
end
