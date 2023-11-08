require("model.input.eval.evalBase")

require("util.string")
require("util.debug")

LuaEval = {}

function LuaEval:new(parser)
  local luaParser = require("model.parser")(parser)
  local eval = function(args)
    return luaParser.parse(args[1])
  end

  local ev = EvalBase:inherit('lua', eval)
  ev.parser = luaParser

  return ev
end
