require("model/eval")

require("util/string")
require("util/debug")

LuaEval = {}

function LuaEval:new()
  local eval = function(text)
    local code = string.join(text, '\n')
    local f, err = load(code)
    -- if f then
    --   pcall(f)
    -- end
    return f, err
  end
  local te = Eval:inherit('lua', eval)

  return te
end
