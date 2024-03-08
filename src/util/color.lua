Color = {
  color = {},
  __index = function(t, c)
    local rc = rawget(Color, c)
    if rc then return rc end
    local bright = c > 7 and 1 or 0.75
    local oc = c
    local b = c % 2
    c = (c - b) / 2
    local r = c % 2
    c = (c - r) / 2
    local g = c % 2
    Color[oc] = { bright * r, bright * g, bright * b, 1 }
    return Color[oc]
  end,

  black = 0,   -- #000000
  blue = 1,    -- #0000bf #0000ff
  red = 2,     -- #bf0000 #ff0000
  magenta = 3, -- #bf01bf #ff01ff
  green = 4,   -- #01bf01 #01ff01
  cyan = 5,    -- #00bfbf #00ffff
  yellow = 6,  -- #bfbf00 #ffff00
  white = 7,   -- #bfbfbf #ffffff
  bright = 8,

  valid = function(c)
    return c
        and type(c) == 'number'
        and math.floor(c) == c -- weird way to isInt
        and c >= 0
        and c < 16
  end,

  --- @param color table
  --- @param alpha number
  with_alpha = function(color, alpha)
    if type(color) == "table" then
      local red, blue, green = color[1], color[2], color[3]
      return { red, green, blue, alpha }
    end
  end
}


setmetatable(Color, Color)
