--- @alias token_id string
--- @alias blocknum integer

--- @class BufferLocation
--- @field block blocknum
--- @field line integer
--- @field lineinfo? lineinfo

--- @class Definition: Assignment
--- @field loc BufferLocation

--- @alias DefBlockMap { [blocknum]: token_id[] }
-- --- @alias DefBlock token_id[][]


--- @class BufferSemanticInfo
--- @field definition Definition[]
