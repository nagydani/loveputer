require("util.string")
local tc = require("util.termcolor")

local INDENT = '  '

local get_indent = function(level, starter)
  local indent = starter or ''
  for _ = 0, level do
    indent = indent .. INDENT
  end
  return indent
end

local text = string.debug_text

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

  text_table = function(t, no_ln, trunc)
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
        if trunc then
          local tr = (function()
            if type(trunc) == 'number' then
              return trunc
            else
              return 20
            end
          end)()
          line = string.usub(line, 1, tr) .. "...'\n"
        end
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
        if type(k) == table then
          res = res .. dent .. Debug.terse_t(k) .. ': '
        else
          res = res .. dent .. k .. ': '
        end
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

  mem = function(o)
    -- TODO: match on color or '0x' and don't pass the label in
    local addr = tostring(o)
    local colons = string.split(addr, ':')
    local typetag = colons[1] or ''
    local mems = tc.colorize_memaddress(colons[2] or '')
    return typetag .. ':' .. mems
  end
}

local printer = (function()
  if orig_print then
    return orig_print
  end
  return print
end)()

local annot = function(tag, color, args)
  local ret = tc.to_control(color)
  ret = ret .. tag .. ': '
  for _, s in ipairs(args) do
    ret = ret .. tostring(s) .. '\t'
  end
  ret = ret .. tc.reset
  return ret
end

-- todo: make this a table, and have this be the __call
Log = {
  info = function(...)
    local args = { ... }
    local s = annot('INFO ', Color.cyan, args)
    printer(s)
  end,
  warning = function(...)
    local args = { ... }
    local s = annot('WARN ', Color.yellow, args)
    printer(s)
  end,
  error = function(...)
    local args = { ... }
    local s = annot('ERROR', Color.red, args)
    printer(s)
  end,

  debug = function(...)
    local args = { ... }
    local s = annot('DEBUG ', Color.blue, args)
    printer(s)
  end,
}

setmetatable(Log, {
  __call = printer
})
