Cursor = {
  l = 0,
  c = 0
}

function Cursor:new(l, c)
  local ll = l or 1
  local cc = c or 1
  return { l = ll, c = cc }
end
