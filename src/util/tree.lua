require('util.table')

--- identity function
local id = function(n) return n end


--- @param node table
--- @param reader function?
local function preorder(node, reader)
  local get = reader or id
  local ret = {}

  if node then
    local val = get(node)
    if val then table.insert(ret, val) end
    if type(node) == "table" then
      for _, child in ipairs(node) do
        local ch = preorder(child, reader)
        for _, v in ipairs(ch) do
          table.insert(ret, v)
        end
      end
    end
  end

  return ret
end


Tree = {
  preorder = preorder,
}
