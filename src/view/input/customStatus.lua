local class = require('util.class')

--- @class CustomStatus table
--- @field content_type ContentType
--- @field line integer?
--- @field block integer?
--- @field range Range?
--- @field buflen integer
--- @field buffer_more More
CustomStatus = class.create()
