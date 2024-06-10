require("model.input.cursor")

--- @class InputSelection
--- @field start Cursor?
--- @field fin Cursor?
--- @field text string[]
--- @field held boolean
InputSelection = {}

function InputSelection:new()
  local s = {
    start = nil,
    fin = nil,
    text = { '' },
    held = false,
  }
  setmetatable(s, self)
  self.__index = self

  return s
end

function InputSelection:is_held()
  return self.held
end
