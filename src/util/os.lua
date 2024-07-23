--- @param cmd string
--- @return boolean success
--- @return string? result
local function runcmd(cmd)
  local handle = io.popen(cmd)
  if handle then
    local result = handle:read("*a")
    handle:close()
    return true, result
  end
  return false
end

return {
  runcmd = runcmd
}
