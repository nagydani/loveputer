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
}


setmetatable(Color, Color)
