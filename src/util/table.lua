--- Create a sequence from the table keys
--- @param t table
--- @param hash boolean?
--- @return table keys
_G.keys = function(t, hash)
  local keys = {}
  for k, _ in pairs(t) do
    if hash then
      keys[k] = k
    else
      table.insert(keys, k)
    end
  end
  return keys
end

--- @param obj table
--- @param seen table?
--- @param omit table?
-- https://gist.github.com/tylerneylon/81333721109155b2d244
function table.clone(obj, seen, omit)
  -- Handle non-tables and previously-seen tables.
  if type(obj) ~= 'table' then return obj end
  if seen and seen[obj] then return seen[obj] end
  -- if omit and omit[obj] then return {} end

  -- New table; mark it as seen and copy recursively.
  local s = seen or {}
  local res = {}
  s[obj] = res
  for k, v in pairs(obj) do
    -- omiting keys only on the main level
    if not omit or (omit and not omit[k]) then
      res[table.clone(k, s)] = table.clone(v, s)
    end
  end
  return setmetatable(res, getmetatable(obj))
end

--- Make table readonly, optionally only the specified fields
--- @param t table
--- @param fields? table
--- @return table protected
--- @return table original
function table.protect(t, fields)
  local orig = t
  local proxy = {}

  setmetatable(proxy, {
    __index = function(_, k)
      return orig[k]
    end,
    __newindex = function(_, k, v)
      if not fields then
        Log("Protected table")
        return
      end
      local fs = {}
      for _, f in ipairs(fields) do
        fs[f] = f
      end
      if fs[k] then
        Log("Can't redefine " .. k)
        return
      end
      orig[k] = v
    end,
  })
  getmetatable(proxy).__metatable = 'no-no'
  t = proxy
  return t, orig
end

function table.pack(...)
  --- @class t
  local t = { ... }
  t.n = #t
  return t
end
