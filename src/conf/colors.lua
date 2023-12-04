local syntax_i = {
  kw_multi   = Color.blue + Color.bright,
  kw_single  = Color.blue,
  number     = Color.magenta,
  string     = Color.green,
  comment    = Color.cyan,
  identifier = Color.black,
  error      = Color.red,
}

return {
  border = Color[Color.black + Color.bright],
  debug = Color[Color.yellow],
  terminal = {
    fg = Color[Color.black],
    bg = Color[Color.white],
  },
  input = {
    bg = Color[Color.white],
    fg = Color[Color.blue + Color.bright],
    cursor = Color[Color.white + Color.bright],
    error = Color[Color.red],
    error_bg = Color[Color.black],
    syntax_i = syntax_i,
    syntax = (function()
      local r = {}
      for k, v in pairs(syntax_i) do
        r[k] = Color[v]
      end
      return r
    end)()
  },
  statusline = {
    fg = Color[Color.white + Color.bright],
    bg = Color[Color.black],
    indicator = Color[Color.cyan + Color.bright],
  },
}
