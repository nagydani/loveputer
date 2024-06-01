--- @class CustomStatus table
--- @field line integer
--- @field buflen integer
--- @field __tostring fun(): string
CustomStatus = {}
CustomStatus.__index = CustomStatus

setmetatable(CustomStatus, {
  __call = function(cls, ...)
    return cls.new(...)
  end,
})

--- @param cfg Config
function CustomStatus.new(cfg)
  local self = setmetatable({
  }, CustomStatus)

  return self
end
