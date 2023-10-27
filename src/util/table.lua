_G.keys = function(t)
  local ret = {}
  for k, _ in pairs(t) do
    table.insert(ret, k)
  end
  return ret
end

-- https://gist.github.com/tylerneylon/81333721109155b2d244
function table.clone(obj, seen)
  -- Handle non-tables and previously-seen tables.
  if type(obj) ~= 'table' then return obj end
  if seen and seen[obj] then return seen[obj] end

  -- New table; mark it as seen and copy recursively.
  local s = seen or {}
  local res = {}
  s[obj] = res
  for k, v in pairs(obj) do res[table.clone(k, s)] = table.clone(v, s) end
  return setmetatable(res, getmetatable(obj))
end
