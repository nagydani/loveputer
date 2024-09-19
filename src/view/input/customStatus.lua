local class = require('util.class')

--- @class CustomStatus table
--- @field content_type ContentType
--- @field buflen integer
--- @field buffer_more More
--- @field selection integer
--- @field range Range?
CustomStatus = class.create(function(ct, len, more, sel, range)
  return {
    content_type = ct,
    buflen = len,
    buffer_more = more,
    selection = sel,
    range = range,
  }
end)

function CustomStatus:__tostring()
  if self.range then
    return 'B' .. self.range
  else
    return 'L' .. self.selection
  end
end
