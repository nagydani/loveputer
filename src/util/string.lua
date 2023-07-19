local utf8 = require("utf8")

StringUtils = {
  normalise_string = function(s)
    return string.gsub(s, "%s+", "")
  end,
  is_non_empty_string = function(s)
    if s and type(s) == 'string' and s ~= '' then
      local normalisedString = string.gsub(s, "%s+", "")
      if normalisedString ~= '' then
        return true
      end
    end
    return false
  end,

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

function StringUtils:is_non_empty_string_array(sa)
  if type(sa) ~= 'table' then
    return false
  else
    for _, s in ipairs(sa) do
      if self.is_non_empty_string(s) then
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
  local pattern = '([^' .. char .. ']+)'
  local words = {}
  for word in string.gmatch(str, pattern) do
    table.insert(words, word)
  end
  return words
end

string.lines = function(s)
  return string.split(s, '\n')
end
