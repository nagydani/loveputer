require("model.input.eval.evalBase")

require("util.string")
require("util.debug")

LuaEval = {}

function LuaEval:new(parser)
  local luaParser = require("model.parser")(parser)
  local eval = function(text)
    local ok, r = luaParser.parse(text)
    return ok, r
  end
  local ev = EvalBase:inherit('lua', eval)
  ev.parser = luaParser

  return ev
end
