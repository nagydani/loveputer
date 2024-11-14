--- @alias token_id string
--- @alias blocknum integer

--- @class BufferLocation
--- @field block blocknum
--- @field line integer
--- @field lineinfo? lineinfo

--- @class Definition
--- @field id token_id
--- @field name string
--- @field loc BufferLocation
-- --- @field type? Type

--- @alias DefBlockMap { [blocknum]: token_id[]}
-- --- @alias DefBlock token_id[][]

--- TODO: come up with a better name
--- @class SemanticDB
--- @field definitions Definition[]
--- @field defmap DefBlockMap
