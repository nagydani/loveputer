local class = require('util.class')

--- Input evaluation error class holding an error message and
--- optionally the location of the error in the input.

--- @class EvalError
--- @field msg string
--- @field c number?
--- @field l number
---
--- @field wrap fun(e: string|EvalError): EvalError?
--- @field __tostring function

--- @param msg string
--- @param c number?
--- @param l number?
local newe = function(msg, c, l)
  return { msg = msg, c = c, l = l }
end

--- @type EvalError
EvalError = class.create(newe)

--- @return EvalError
function EvalError.wrap(e)
  if type(e) == "string" then
    return EvalError(e)
  end
  if type(e) == "table" and type(e.msg) == "string" then
    return e
  end
  return EvalError(tostring(e))
end

function EvalError:__tostring()
  local li = ''
  if self.l then
    li = li .. 'L' .. self.l .. ':'
    if self.c then
      li = li .. self.c .. ':'
    end
  end
  return li .. self.msg
end
