require("util/string")

local INDENT = '  '

local get_indent = function(level, starter)
  local indent = starter or ''
  for _ = 0, level do
    indent = indent .. INDENT
  end
  return indent
end

local text = function(t)
  if not t or type(t) ~= 'string' then return end
  return string.format("'%s'", t)
end

Debug = {
  print_t = function(t, tag, level, prev_seen)
    local seen = prev_seen or {}
    local indent = level or 0

    if not t then return '' end
    local res = ''

    if tag then
      res = '[' .. tag .. ']'
    end
    if type(t) == 'table' then
      if seen[t] then return '' end
      seen[t] = true
      for k, v in pairs(t) do
        local ts = Debug.print_t(v, nil, indent + 1, seen)
        if ts then
          local header = get_indent(indent) .. '---- ' .. k .. ' ----\n'
          res = res .. get_indent(indent) .. header
          res = res .. get_indent(indent) .. ts
          res = res .. '\n'
        end
      end
    elseif type(t) == 'string' then
      res = res .. get_indent(indent) .. t .. '\n'
    elseif type(t) == 'function' then
      -- res = res .. get_indent(indent) .. 'f() ' .. string.dump(t) .. '\n'
      -- res = res .. get_indent(indent, '    ') .. 'end\n'
      res = res .. get_indent(indent) .. 'f() ' .. '' .. 'end\n'
    elseif type(t) == 'number' then
      res = res .. get_indent(indent) .. 'N ' .. t .. '\n'
    end
    return res
  end,

  text = text,

  text_table = function(t, no_ln)
    local res = ''
    if t then
      for i, l in ipairs(t) do
        local line = (function()
          if not no_ln then
            return string.format("#%02d: %s\n", i, text(l))
          else
            return text(l) .. '\n'
          end
        end)()
        res = res .. line
      end
    end
    return res
  end,

  terse_t = function(t, level, prev_seen)
    if not t then return '' end

    local seen = prev_seen or {}
    local indent = level or 0
    local res = ''
    local flat = true
    if type(t) == 'table' then
      res = res .. '{'
      if seen[t] then return '' end
      seen[t] = true
      for k, v in pairs(t) do
        local dent = ''
        if type(v) == 'table' then
          flat = false
          dent = '\n' .. string.times('  ', indent + 1)
        end
        res = res .. dent .. Debug.terse_t(k) .. ': '
        res = res .. Debug.terse_t(v, indent + 1, seen)
      end
      local br = (function()
        if flat then return '' else return '\n' end
      end)()
      local dent = br .. string.times('  ', indent)
      res = res .. dent .. '}, '
    elseif type(t) == 'string' then
      res = res .. text(t) .. ', '
    else
      res = res .. tostring(t) .. ', '
    end

    return res
  end,
}
