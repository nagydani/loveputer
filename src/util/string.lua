local utf8 = require("utf8")

StringUtils = {
  -- TODO: move to string table too
  -- original from http://lua-users.org/lists/lua-l/2014-04/msg00590.html
  utf8_sub = function(s, i, j)
    i = i or 1
    j = j or -1
    if i < 1 or j < 1 then
      local n = utf8.len(s)
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
  end,
}

string.normalize = function(s)
  return string.gsub(s, "%s+", "")
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
      return false
    end
  end
end

string.ulen = function(s)
  return utf8.len(s or '')
end

string.split_at = function(s, i)
  local pre, post = '', ''
  local ulen = utf8.len(s)
  if ulen ~= #s then -- branch off for UTF-8
    pre = StringUtils.utf8_sub(s, 1, i - 1)
    post = StringUtils.utf8_sub(s, i)
  else
    pre = string.sub(s, 1, i - 1)
    post = string.sub(s, i, #s)
  end
  return pre, post
end

string.split = function(str, char)
  if not type(str) == 'string' then return {} end
  local pattern = '([^' .. char .. ']+)'
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
  if not strs or type(strs) ~= 'table' then return res end
  local j = char or ' '
  for i, word in ipairs(strs) do
    res = res .. word
    if i ~= #strs then
      res = res .. j
    end
  end
  return res
end
