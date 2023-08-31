Debug = {
  print_t = function(t, tag, ind, prev_seen)
    local seen = prev_seen or {}
    local indent = ind or 0
    local function get_indent(starter)
      local dent = starter or ''
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
      if seen[t] then return end
      seen[t] = true
      for k, v in pairs(t) do
        local ts = Debug.print_t(v, nil, indent + 1, seen)
        if ts then
          local header = get_indent() .. '---- ' .. k .. ' ----\n'
          res = res .. get_indent() .. header
          res = res .. get_indent() .. ts
          res = res .. '\n'
        end
      end
    elseif type(t) == 'string' then
      res = res .. get_indent() .. t .. '\n'
    elseif type(t) == 'function' then
      res = res .. get_indent() .. 'f() ' .. '' .. '\n'
      -- res = res .. get_indent() .. 'f() ' .. string.dump(t) .. '\n'
      res = res .. get_indent('    ') .. 'end\n'
    elseif type(t) == 'number' then
      res = res .. get_indent() .. 'N ' .. t .. '\n'
    end
    return res
  end,

  text_table = function(t, no_ln)
    local res = ''
    if t then
      for i, l in ipairs(t) do
        local line = (function()
          if not no_ln then
            return string.format("#%02d: '%s'\n", i, l)
          else
            return string.format("'%s'\n", l)
          end
        end)()
        res = res .. line
      end
    end
    return res
  end,
}
