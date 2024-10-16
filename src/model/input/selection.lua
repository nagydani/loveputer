require("model.input.cursor")

local class = require('util.class')

--- @class InputSelection
--- @field start Cursor?
--- @field fin Cursor?
--- @field text string[]
--- @field held boolean
InputSelection = class.create(function()
  return {
    --- not a Range, because the ends are optional
    start = nil,
    fin = nil,
    text = { '' },
    held = false,
  }
end)

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
