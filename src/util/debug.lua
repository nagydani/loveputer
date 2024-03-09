require("util.string")
local tc = require("util.termcolor")

local INDENT = '  '

local seen = {}

--- @param level integer
--- @param starter string?
local get_indent = function(level, starter)
  local indent = starter or ''
  for _ = 0, level do
    indent = indent .. INDENT
  end
  return indent
end

local text = string.debug_text

Debug = {
  --- @param t table
  --- @param tag string?
  --- @param level integer
  --- @param prev_seen table?
  --- @return string
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
      res = res .. get_indent(indent) .. Debug.mem(t) .. '\n'
      -- res = res .. get_indent(indent) .. 'f() ' .. string.dump(t) .. '\n'
      -- res = res .. get_indent(indent, '    ') .. 'end\n'
      res = res .. get_indent(indent) .. 'f() ' .. '' .. 'end\n'
    elseif type(t) == 'number' then
      res = res .. get_indent(indent) .. 'N ' .. t .. '\n'
    end
    return res
  end,

  text = text,

  --- @param t table
  --- @param no_ln boolean?
  --- @param trunc boolean?
  --- @return string
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

  --- @param t table
  --- @param level integer?
  --- @param prev_seen table?
  ---@return string
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
    elseif type(t) == 'function' then
      res = res .. Debug.mem(t) .. ', '
    else
      res = res .. tostring(t) .. ', '
    end

    return res
  end,

  --- @param o any
  --- @return string
  mem = function(o)
    -- TODO: match on color or '0x' and don't pass the label in
    local addr = tostring(o)
    local colons = string.split(addr, ':')
    local typetag = colons[1] or ''
    local mems = tc.colorize_memaddress(colons[2] or '')
    return typetag .. ':' .. mems
  end,

  --- @param t table
  --- @param terse boolean?
  --- @return string
  keys = function(t, terse)
    local sep = (function()
      if terse then return ', ' else return '\n' end
    end)()
    local ret = '{ '
    if not terse then ret = ret .. '\n' end
    for k in pairs(table.keys(t)) do
      ret = ret .. k .. sep
    end
    if not terse then ret = ret .. '\n' end
    ret = ret .. '}'
    return ret
  end,

  --- @param terminal Terminal
  --- @param lineN integer?
  termdebug = function(terminal, lineN)
    if not terminal or not terminal.buffer then
      return
    end
    if lineN and type(lineN) == "number" then
      local line = terminal.buffer[lineN] or ' ⨯⨯⨯ out of bounds ⨯⨯⨯ '
      return string.format('%d │%s│', lineN, string.join(line))
    else
      local w = terminal.width
      local top = '┌' .. string.times('─', w) .. '┐'
      local bottom = '└' .. string.times('─', w) .. '┘'
      local lines = {}
      for i, v in ipairs(terminal.buffer) do
        lines[i] = '│' .. string.join(v, '') .. '│'
      end
      table.insert(lines, 1, '\n' .. top)
      table.insert(lines, bottom)
      return string.join(lines, '\n')
    end
  end,
}

local printer = (function()
  if orig_print then
    return orig_print
  end
  return print
end)()

--- @param tag string
--- @param color integer
--- @param args table
--- @return string
local annot = function(tag, color, args)
  local ret = tc.to_control(color)
  ret = ret .. tag .. ': '
  for _, s in ipairs(args) do
    ret = ret .. tostring(s) .. '\t'
  end
  ret = ret .. tc.reset
  return ret
end

local warning = function(...)
  local args = { ... }
  local s = annot('WARN ', Color.yellow, args)
  printer(s)
end
local error = function(...)
  local args = { ... }
  local s = annot('ERROR', Color.red, args)
  printer(s)
end

--- @param s string
local function hash(s)
  local bit = require('bit')
  -- http://www.cs.yorku.ca/~oz/hash.html

  -- local h = 0
  -- for c in string.gmatch(s, utf8.charpattern) do
  --   local p = utf8.codepoint(c)
  --   h = p + bit.lshift(h, 6) + bit.lshift(h, 16) - h
  -- end

  local h = 5381
  for ch in string.gmatch(s, utf8.charpattern) do
    local c = utf8.codepoint(ch)
    h = (bit.lshift(h, 5) + h + c)
  end

  -- h = h ^ ((bit.lshift(h, 5)) + (bit.rshift(h, 2)) + p)
  -- h = ((h << 5) + h) + c
  -- h = h ^ ((h<<5)+(h>>2)+c)
  return h
end

Log = {
  info = function(...)
    local args = { ... }
    local s = annot('INFO ', Color.cyan, args)
    printer(s)
  end,
  warning = warning,
  warn = warning,
  error = error,
  err = error,

  debug = function(...)
    local args = { ... }
    local ts = string.format("%.3f ", os.clock())
    local s = annot(ts .. 'DEBUG ', Color.blue, args)
    printer(s)
  end,

  once = function(...)
    local args = { ... }
    local key = string.join(args, '')
    local kh = hash(key)
    if not seen[kh] then
      Log.debug(Debug.terse_t(seen))
      seen[kh] = true
      local s = annot('ONCE  ', Color.white, args)
      printer(s)
    end
  end,
}

setmetatable(Log, {
  __call = printer
})
