require("util/string")

function parse_load_error(err)
  if string.is_non_empty_string(err) then
    local colons = string.split(err, ':')
    return string.trim(colons[3]) or ''
  end
end
