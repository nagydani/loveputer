Debug = {
  printT = function(t, tag, ind)
    local indent = ind or 0
    local function getIndent()
      local dent = ''
      for i = 0, indent do
        dent = dent .. '  '
      end
      return dent
    end

    if not t then return '' end
    local res = ''

    if tag then
      res = '[' .. tag .. ']'
    end
    if type(t) == 'table' then
      for k, v in pairs(t) do
        local header = getIndent() .. '---- ' .. k .. ' ----\n'
        res = res .. getIndent() .. header
        res = res .. getIndent() .. Debug.printT(v, nil, indent + 1)
        res = res .. '\n'
      end
    elseif type(t) == 'string' then
      res = res .. getIndent() .. t .. '\n'
    elseif type(t) == 'function' then
      res = res .. getIndent() .. 'f() ' .. t .. '\n'
    end
    return res
  end
}
