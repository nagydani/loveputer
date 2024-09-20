local class = require('util.class')

--- @class ParseError
--- @field l number
--- @field c number
--- @field msg string

ParseError = class.create(function(l, c, msg)
  return { l = l, c = c, msg = msg }
end)
