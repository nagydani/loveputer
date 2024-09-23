require("util.string")

local function get_call_error(err)
  if string.is_non_empty_string(err) then
    local colons = string.split(err, ':')
    table.remove(colons, 1)
    table.remove(colons, 1)
    return string.trim(string.join(colons, ':')) or ''
  end
end

local function eval(s)
  local expr = loadstring('return ' .. s)
  if not expr then return end
  local ok, res = pcall(expr)
  if ok then return res end
end


return {
  get_call_error = get_call_error,
  eval = eval,
}
