require("util.color")

local reset = '\27[0m'

---@param ci number
---@return string
local to_control = function(ci)
  if type(ci) ~= 'number' or ci < 0 or ci > 15 then
    return reset
  end
  local bright = ''
  if ci > Color.bright then
    bright = '1;'
  end
  local fg = {
    -- a bit of cheating, so it's visible
    [Color.black]                  = '38;5;238',
    [Color.red]                    = '31',
    [Color.green]                  = '32',
    [Color.yellow]                 = '33',
    [Color.blue]                   = '34',
    [Color.magenta]                = '35',
    [Color.cyan]                   = '36',
    [Color.white]                  = '37',
    [Color.bright + Color.black]   = '90',
    [Color.bright + Color.red]     = '91',
    [Color.bright + Color.green]   = '92',
    [Color.bright + Color.yellow]  = '93',
    [Color.bright + Color.blue]    = '94',
    [Color.bright + Color.magenta] = '95',
    [Color.bright + Color.cyan]    = '96',
    [Color.bright + Color.white]   = '97',
  }
  return "\27[" .. bright .. fg[ci] .. "m"
end

---@param ci number
---@param s string
---@param part boolean?
---@return string
local colorize = function(ci, s, part)
  if part then
    return (to_control(ci) .. s)
  else
    return (to_control(ci) .. s .. reset)
  end
end

return {
  reset = reset,
  to_control = to_control,

  colorize = colorize,
  --- Colorize memory addresses for easier visual comparison.
  ---
  --- This will not support UTF-8, you're supposed to feed it hex strings
  ---@param a string
  ---@return string
  colorize_memaddress = function(a)
    local ret = reset
    for i = 1, string.len(a) do
      local c = string.sub(a, i, i)
      local cc = ''

      local b = string.byte(c)
      if b > 47 and b < 58 then -- 0-9
        cc = to_control(b - 48)
        ret = ret .. cc .. c .. reset
      elseif b > 96 and b < 103 then -- a-f
        cc = to_control(b - 97 + 10)
        ret = ret .. cc .. c .. reset
      else
        ret = ret .. c
      end
    end
    return ret
  end,

  ---@param ci number?
  ---@param s string
  ---@param part boolean?
  print_c = function(ci, s, part)
    local output = (function()
      if ci then
        return colorize(ci, s, part)
      end
      return s
    end)()
    if part then
      io.write(output)
    else
      print(output)
    end
  end
}
