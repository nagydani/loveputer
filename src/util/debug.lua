Debug = {
  print_t = function(t, tag, ind)
    local indent = ind or 0
    local function get_indent()
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
        local header = get_indent() .. '---- ' .. k .. ' ----\n'
        res = res .. get_indent() .. header
        res = res .. get_indent() .. Debug.print_t(v, nil, indent + 1)
        res = res .. '\n'
      end
    elseif type(t) == 'string' then
      res = res .. get_indent() .. t .. '\n'
    elseif type(t) == 'function' then
      res = res .. get_indent() .. 'f() ' .. t .. '\n'
    elseif type(t) == 'number' then
      res = res .. get_indent() .. 'N ' .. t .. '\n'
    end
    return res
  end
}
