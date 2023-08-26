require("util/color")
local c = require("conf/colors").input
local colors = c.syntax_i

local types = {
  kw_multi   = true, -- 'Keyword'
  kw_single  = true, -- 'Keyword'
  number     = true, -- 'Number'
  string     = true, -- 'String'
  comment    = true,
  identifier = true, -- 'Id'
}

local tokenHL = {
  colorize = function(t)
    local type = types[t]
    if not type then
      return c.fg
    else
      return colors[t]
    end
  end,
}

return tokenHL
