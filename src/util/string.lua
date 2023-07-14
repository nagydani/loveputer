local utf8 = require("utf8")

StringUtils = {
  is_non_empty_string = function(s)
    if s and s ~= '' then
      local normalisedString = string.gsub(s, "%s+", "")
      if normalisedString ~= '' then
        return true
      end
    end
    return false
  end,

  to_utf8_index = function(s, i)
    local ui = utf8.offset(s, i)
    return ui
  end,

  split_at = function(s, i)
    local pre = ''
    local post = ''
    pre = string.sub(s, 1, i - 1)
    post = string.sub(s, i, #s)
    return pre, post
  end,

  utf8_split_at = function(s, i)
    local pre = ''
    local post = ''
    local j = 1
    for _, c in utf8.codes(s) do
      if j < i then
        pre = pre .. utf8.char(c)
      else
        post = post .. utf8.char(c)
      end
      j = j + 1
    end
    return pre, post
  end,

  -- utf8_sub = function(s, i, j)
  --   local ml = utf8.len(s)
  --   if ml <= j then j = ml end

  --   i = utf8.offset(s, i)
  --   j = utf8.offset(s, j + 1) - 1
  --   return string.sub(s, i, j)
  -- end,

  utf8_sub_full = function(s, i, j)
    i = i or 1
    j = j or -1
    if i < 1 or j < 1 then
      local n = utf8.len(s)
      if not n then return nil end
      if i < 0 then i = n + 1 + i end
      if j < 0 then j = n + 1 + j end
      if i < 0 then i = 1 elseif i > n then i = n end
      if j < 0 then j = 1 elseif j > n then j = n end
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
