require('util.table')

--- @alias blocknum integer

--- @class Definition: Assignment
--- @field block blocknum

--- @class BufferSemanticInfo
--- @field definitions Definition[]

--- @param si SemanticInfo
--- @param rev table
--- @return BufferSemanticInfo
local function convert(si, rev)
  local as = si.assignments
  local defs = table.map(as, function(a)
    local r = table.clone(a)
    r.block = rev[a.line]
    return r
  end)
  return {
    definitions = defs,
  }
end

return {
  convert = convert,
}
