local utf8
if _VERSION == 'Lua 5.1' and not love then
  utf8 = require("lua-utf8")
else
  utf8 = require("utf8")
end

return utf8
