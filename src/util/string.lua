local utf8 = require("utf8")

string.normalize = function(s)
  return string.gsub(s, "%s+", "")
end
string.trim = function(s)
  if not s then return '' end
  local pre = string.gsub(s, "^%s+", "")
  local post = string.gsub(pre, "%s+$", "")
  return post
end

string.is_non_empty_string = function(s)
  if s and type(s) == 'string' and s ~= '' then
    if string.normalize(s) ~= '' then
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
  return utf8.len(s or '')
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
  local len = string.ulen(s)
  local mod = math.floor(i)
  local n = math.floor(len / mod)
  local res = {}
  local chunk = ''
  local rem = s
  for _ = 1, n do
    chunk, rem = string.split_at(rem, mod + 1)
    table.insert(res, chunk)
  end
  if string.is_non_empty_string(rem) then
    table.insert(res, rem)
  end

  return res
end

string.split = function(str, char)
  if not type(str) == 'string' then return {} end
  local pattern = string.interleave('([^', char, ']+)')
  local words = {}
  for word in string.gmatch(str, pattern) do
    table.insert(words, word)
  end
  return words
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
