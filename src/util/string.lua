local utf8
if _VERSION == 'Lua 5.1' and not love then
  utf8 = require("lua-utf8")
else
  utf8 = require("utf8")
end

string.debug_text = function(t)
  if not t or type(t) ~= 'string' then return end
  return string.format("'%s'", t)
end

string.normalize = function(s)
  return string.gsub(s, "%s+", "")
end
string.trim = function(s)
  if not s then return '' end
  local pre = string.gsub(s, "^%s+", "")
  local post = string.gsub(pre, "%s+$", "")
  return post
end

string.is_non_empty_string = function(s, no_trim)
  if s and type(s) == 'string' and s ~= '' then
    local str = (function()
      if no_trim then
        return s
      else
        return string.normalize(s)
      end
    end)()
    if str ~= '' then
      return true
    end
  end
  return false
end

string.is_non_empty_string_array = function(sa)
  if type(sa) ~= 'table' then
    return false
  else
    for _, s in ipairs(sa) do
      if string.is_non_empty_string(s) then
        return true
      end
    end
    return false
  end
end

string.ulen = function(s)
  if s then
    return utf8.len(s)
  else
    return 0
  end
end

-- original from http://lua-users.org/lists/lua-l/2014-04/msg00590.html
string.usub = function(s, i, j)
  i = i or 1
  j = j or -1
  if i < 1 or j < 1 then
    local n = string.ulen(s)
    if not n then return '' end
    if i > n then return '' end
    if i < 0 then i = n + 1 + i end
    if j < 0 then
      j = n + 1 + j
    end
    if i < 0 then i = 1 elseif i > n then i = n end
    if j < 0 then
      j = 1
    elseif j > n then
      j = n
    end
  end
  if j < i then return "" end
  i = utf8.offset(s, i)
  j = utf8.offset(s, j + 1)
  if i and j then
    return s:sub(i, j - 1)
  elseif i then
    return s:sub(i)
  else
    return ""
  end
end

string.split_at = function(s, i)
  local str = s or ''
  local pre, post = '', ''
  local ulen = string.ulen(str)
  if ulen ~= #str then -- branch off for UTF-8
    pre = string.usub(str, 1, i - 1)
    post = string.usub(str, i)
  else
    pre = string.sub(str, 1, i - 1)
    post = string.sub(str, i, #str)
  end
  return pre, post
end

string.wrap_at = function(s, i)
  if
      not s or type(s) ~= 'string' or s == '' or
      not i or type(i) ~= 'number' or i < 1 then
    return { '' }
  end
  local len = string.ulen(s) or 0
  local mod = math.floor(i)
  local n = math.floor(len / mod)
  local res = {}
  local chunk = ''
  local rem = s
  for _ = 1, n do
    chunk, rem = string.split_at(rem, mod + 1)
    table.insert(res, chunk)
  end
  if string.is_non_empty_string(rem, true) then
    table.insert(res, rem)
  end

  return res
end

-- https://stackoverflow.com/a/51893646
string.split = function(str, delimiter)
  if str and type(str) == 'string' and string.is_non_empty_string(str, true) then
    local result               = {}
    local from                 = 1
    local delim_from, delim_to = string.find(str, delimiter, from)
    while delim_from do
      table.insert(result, string.sub(str, from, delim_from - 1))
      from                 = delim_to + 1
      delim_from, delim_to = string.find(str, delimiter, from)
    end
    table.insert(result, string.sub(str, from))
    return result
  else
    return {}
  end
end

string.split_array = function(str_arr, char)
  if not type(str_arr) == 'table' then return {} end
  local words = {}
  for _, line in ipairs(str_arr) do
    local ws = string.split(line, char)
    for _, word in ipairs(ws) do
      table.insert(words, word)
    end
  end
  return words
end

string.lines = function(s)
  if type(s) == 'string' then
    return string.split(s, '\n')
  end
  if type(s) == 'table' then
    return string.split_array(s, '\n')
  end
end


string.join = function(strs, char)
  local res = ''
  if type(strs) == 'table' then
    local j = char or ' '
    for i, word in ipairs(strs) do
      res = res .. word
      if i ~= #strs then
        res = res .. j
      end
    end
  end
  if type(strs) == 'string' then
    res = strs
  end
  return res
end

string.interleave = function(prefix, text, postfix)
  return string.join({ prefix, postfix }, text)
end

string.splice = function(str, si, ei)
  if not str or type(str) ~= 'string'
      or not string.is_non_empty_string(str, true) or si > ei then
    return '', '', ''
  end
  local l = string.ulen(str)
  local start = si or 1
  local fin = ei or l
  local split1 = start + 1
  local split2 = fin - start + 1
  local pre, rem = string.split_at(str, split1)
  local mid, post = string.split_at(rem, split2)
  return pre, mid, post
end

string.times = function(s, n)
  local till = n or 1
  local str = s or ''
  local res = ''
  for _ = 1, till do
    res = res .. str
  end
  return res
end
