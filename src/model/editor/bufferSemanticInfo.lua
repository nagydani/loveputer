require('util.table')

-- @class BufferLocation
-- @field line integer
-- @field lineinfo? lineinfo

--- @class Definition: Assignment
--- @field block blocknum
-- @field loc BufferLocation

--- @alias token_id string
--- @alias blocknum integer
--- @alias DefBlockMap { [blocknum]: token_id[] }
-- --- @alias DefBlock token_id[][]


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
