require("view/color")

local reset = '\27[0m'
local to_control = function(ci)
  if not ci or type(ci) ~= 'number' or ci < 0 or ci > 15 then
    return reset
  end
  local bright = ''
  local i = ci
  if ci > Color.bright then
    bright = '1;'
    i = ci - Color.bright
  end
  local fg = {
    [Color.black]   = '38;5;238', -- a bit of cheating, so it's visible
    [Color.red]     = '31',
    [Color.green]   = '32',
    [Color.yellow]  = '33',
    [Color.blue]    = '34',
    [Color.magenta] = '35',
    [Color.cyan]    = '36',
    [Color.white]   = '37',
  }
  return "\27[" .. bright .. fg[i] .. "m"
end

return {
  reset = reset,
  to_control = to_control,

  print_c = function(ci, s)
    print(to_control(ci) .. s .. reset)
  end
}
