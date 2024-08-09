require("util.string")
require("util.table")
local tc = require("util.termcolor")
local OS = require("util.os")

local tab = '  '


--- @param level integer
--- @param starter string?
local get_indent = function(level, starter)
  local indent = starter or ''
  for _ = 0, level do
    indent = indent .. tab
  end
  return indent
end

local text = string.debug_text


--- @param t table?
--- @param level integer?
--- @param prev_seen table?
--- @param jsonify boolean?
--- @return string
local function terse_hash(t, level, prev_seen, jsonify)
  if not t then return '' end

  local seen = prev_seen or {}
  local indent = level or 0
  local res = ''
  local flat = true
  if type(t) == 'table' then
    res = res .. string.times(tab, indent) .. '{'
    if seen[t] then return '' end
    seen[t] = true

    for k, v in pairs(t) do
      local dent = ''
      if type(v) == 'table' then
        flat = false
        dent = '\n' .. string.times(tab, indent + 1)
      end

      if type(k) == 'table' then
        res = res .. dent .. Debug.terse_hash(k, nil, nil, jsonify) .. ': '
      else
        res = res .. dent .. k .. ': ' -- .. '// [' .. type(v) .. ']  '
      end
      if type(v) == 'table' then
        local table_text = Debug.terse_hash(v, indent + 1, seen, jsonify)
        if string.is_non_empty_string(table_text, true) then
          res = res .. '\n' .. tab .. table_text
        else
          res = res .. '{},' .. '\n' .. string.times(tab, indent + 1)
        end
      elseif type(v) == nil and jsonify then
        res = res .. 'null, '
      elseif type(v) == 'boolean' and v == false then
        res = res .. 'false, '
      else
        res = res .. Debug.terse_hash(v, indent + 1, seen, jsonify)
      end
    end
    local br = (function()
      if flat then return '' else return '\n' end
    end)()
    local dent = br .. string.times(tab, indent)
    res = res .. dent .. '}, '
  elseif type(t) == 'string' then
    local t_ = (function()
      if jsonify then
        local l = string.lines(t)
        return string.join(l, '\\n')
      end
      return t
    end)()
    res = res .. text(t_) .. ', '     --.. '// [' .. type(t) .. ']  '
  elseif type(t) == 'function' then
    res = res .. Debug.mem(t) .. ', ' --.. '// [' .. type(t) .. ']  '
  else
    res = res .. tostring(t) .. ', '  --.. '// [' .. type(t) .. ']  '
  end

  return res
end

--- @param a table?
local function terse_array(a)
  if type(a) == 'table' then
    local res = '['
    for i, v in ipairs(a) do
      res = res .. string.format('\n/* %d */\n%s', i, terse_hash(v, 1, {}))
      -- res = res .. string.format('\n/* %d */\n%s', i, '{ ... }')
    end
    res = res .. '\n]'
    return res
  else
    return ''
  end
end

Debug = {
  --- @param t table
  --- @param tag string?
  --- @param level integer?
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

  --- @param t string[]?
  --- @param no_ln boolean?
  --- @param trunc boolean?
  --- @return string
  text_table = function(t, no_ln, trunc)
    local res = '\n'
    if type(t) == 'table' then
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

  terse_hash = terse_hash,
  terse_array = terse_array,
  terse_t = function(t, ...)
    if t and type(t) == "table" then
      if table.is_array(t) then
        return terse_array(t)
      else
        return terse_hash(t, ...)
      end
    end
  end,
  -- terse_hash, -- TODO: branch on is_array

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
      return string.unlines(lines)
    end
  end,

  --- @param content string|string[]
  --- @param ext string?
  --- @param fixname string?
  write_tempfile = function(content, ext, fixname)
    local function create_temp()
      local cmd = 'mktemp -u -p .'
      if string.is_non_empty_string(ext) then
        cmd = string.format('%s --suffix .%s', cmd, ext)
      end
      local _, result = OS.runcmd(cmd)
      return result
    end
    local name =
        string.is_non_empty_string(fixname)
        and fixname .. (ext and '.' .. ext or '')
        or create_temp()
    local path = string.join_path('./.debug', name)

    local data = string.unlines(content)
    local FS = require('util.filesystem')
    FS.write(path, data)
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
    local c
    if pcall(function() utf8.codepoint(ch) end) then
      c = utf8.codepoint(ch)
    else
      c = 0
    end
    h = (bit.lshift(h, 5) + h + c)
  end

  -- h = h ^ ((bit.lshift(h, 5)) + (bit.rshift(h, 2)) + p)
  -- h = ((h << 5) + h) + c
  -- h = h ^ ((h<<5)+(h>>2)+c)
  return h
end

local once_seen = {}
local once_color = Color.white + Color.bright

local function once(kh, args)
  if not once_seen[kh] then
    once_seen[kh] = true
    local s = annot('ONCE  ', once_color, args)
    printer(s)
  end
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
    if not love.DEBUG then return end
    local args = { ... }
    local key = love.debug.once .. string.join(args, '')
    local kh = hash(key)
    once(kh, args)
  end,

  fire_once = function()
    if not love.DEBUG then return end
    love.debug.once = love.debug.once + 1
  end,
  --- @param color integer
  set_once_color = function(color)
    if color >= 0 and
        color <= 15 then
      once_color = color
    end
  end,
}

setmetatable(Log, {
  __call = printer
})
