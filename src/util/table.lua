_G.keys = function(t)
  local ret = {}
  for k, _ in pairs(t) do
    table.insert(ret, k)
  end
  return ret
end
