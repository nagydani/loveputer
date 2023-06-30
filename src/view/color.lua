Color = {
  indices = {
    black = 0,
    blue = 1,
    red = 2,
    magenta = 3,
    green = 4,
    cyan = 5,
    yellow = 6,
    white = 7,
    bright = 8,
  },
  color = {},
  __index = function(t, c)
    if t.color[c] then return t.color[c] end
    local ci = t.indices[c]
    local bright = ci > 7 and 1 or 0.75
    local b = ci % 2
    ci = (ci - b) / 2
    local r = ci % 2
    ci = (ci - r) / 2
    local g = ci % 2
    t.color[c] = { bright * r, bright * g, bright * b, 1 }
    return t.color[c]
  end,
}

setmetatable(Color, Color)
