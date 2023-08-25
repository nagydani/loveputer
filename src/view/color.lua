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

  black = 0,
  blue = 1,
  red = 2,
  magenta = 3,
  green = 4,
  cyan = 5,
  yellow = 6,
  white = 7,
  bright = 8,
}


setmetatable(Color, Color)
