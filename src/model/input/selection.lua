require("model.input.cursor")

--- @class InputSelection
--- @field start Cursor?
--- @field fin Cursor?
--- @field text string[]
--- @field held boolean
InputSelection = {}

function InputSelection:new()
  local s = {
    --- TODO refactor this into a Range
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

function InputSelection:__tostring()
  local s = self.start
  local e = self.fin
  local held = (function()
    if self.held then return 'v' else return '^' end
  end)()
  return string.format('{%d-%d}[%d]', s, e, held)
end
