require("model.input.eval.eval")

require("util.string")
require("util.debug")

LuaEval = {}

function LuaEval:new(parser)
  local luaParser = require("model.parser")(parser)
  local eval = function(text)
    local code = string.join(text, '\n')
    local ok, r = luaParser.parse(code)
    return ok, r
  end
  local ev = Eval:inherit('lua', eval)
  ev.parser = luaParser

  return ev
end
