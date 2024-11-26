require("util.color")
local c = require("conf.colors").input
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
  --- @return integer?
  colorize = function(t)
    local type = types[t]
    if type then
      return colors[t]
    end
  end,
}

return tokenHL
