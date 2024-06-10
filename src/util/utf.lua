return (function()
  if _VERSION == 'Lua 5.1' and not love then
    return require("lua-utf8")
  else
    return require("utf8")
  end
end)()
