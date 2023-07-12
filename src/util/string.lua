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
    -- local al = utf8.len(s)
    local ui = utf8.offset(s, i)
    return ui
  end,
}
