local class = require('util.class')

--- @class CustomStatus table
--- @field content_type ContentType
--- @field buflen integer
--- @field buffer_more More
--- @field selection integer
--- @field range Range?
CustomStatus = class.create()

function CustomStatus:__tostring()
  if self.range then
    return 'B' .. self.range
  else
    return 'L' .. self.selection
  end
end
