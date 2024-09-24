local class = require('util.class')

--- Input evaluation error class holding an error message and
--- optionally the location of the error in the input.

--- @class EvalError
--- @field msg string
--- @field c number?
--- @field l number

--- @param msg string
--- @param c number?
--- @param l number?
local newe = function(msg, c, l)
  local ll = l or 1
  return { msg = msg, c = c, l = ll }
end

--- @type EvalError
EvalError = class.create(newe)
