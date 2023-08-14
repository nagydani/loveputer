require("model/eval")

require("util/string")
require("util/debug")

LuaEval = {}

function LuaEval:new(parser)
  local parser = require("model/parser")(parser)
  local eval = function(text)
    local code = string.join(text, '\n')
    local ok, r = parser.parse(code)
    -- local f, err = load(code)
    -- if f then
    --   pcall(f)
    -- end
    return ok, r
  end
  local ev = Eval:inherit('lua', eval)

  return ev
end
