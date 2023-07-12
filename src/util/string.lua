StringUtils = {
  is_non_empty_string = function(s)
    if s and s ~= '' then
      local normalisedString = string.gsub(s, "%s+", "")
      if normalisedString ~= '' then
        return true
      end
    end
    return false
  end
}
