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

}
