--- @class CustomStatus table
--- @field content_type ContentType
--- @field line integer?
--- @field block integer?
--- @field range Range?
--- @field buflen integer
--- @field more More
CustomStatus = {}
CustomStatus.__index = CustomStatus

setmetatable(CustomStatus, {
  __call = function(cls, ...)
    return cls.new(...)
  end,
})

function CustomStatus.new()
  local self = setmetatable({
  }, CustomStatus)

  return self
end
