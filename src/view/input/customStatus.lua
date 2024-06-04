--- @class CustomStatus table
--- @field line integer
--- @field buflen integer
--- @field more More
--- @field __tostring fun(): string
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
