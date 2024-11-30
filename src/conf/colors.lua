local syntax_i = {
  kw_multi   = Color.blue + Color.bright,
  kw_single  = Color.blue,
  number     = Color.magenta,
  string     = Color.green,
  comment    = Color.cyan,
  identifier = Color.black,
  error      = Color.red,
}

---@alias InputTheme
---| 'console'
---| 'user'
---| 'inspect'
---| 'editor'

---@alias RGB integer[]

--- @class BaseColors
--- @field bg RGB
--- @field fg RGB

--- @class EditorColors : BaseColors
--- @field highlight RGB
--- @field highlight_loaded RGB
--- @field highlight_special RGB

--- @class InputColors
--- @field console BaseColors
--- @field user BaseColors
--- @field inspect BaseColors
--- @field cursor RGB
--- @field error RGB  -- TODO pair these
--- @field error_bg RGB  -- TODO pair these
--- @field syntax_i table
--- @field syntax table

--- @class StatuslineColors
--- @field bg RGB
--- @field fg RGB
--- @field fg2 RGB?
--- @field indicator RGB
--- @field special RGB

local indicator = Color[Color.cyan + Color.bright]
local special = Color[Color.cyan]
--- @class Colors
--- @field border RGB
--- @field debug RGB
--- @field terminal BaseColors
--- @field editor EditorColors
--- @field input InputColors
--- @field statusline table<InputTheme, StatuslineColors>
return {
  border = Color[Color.black + Color.bright],
  debug = Color[Color.yellow],
  terminal = {
    fg = Color[Color.black],
    bg = Color[Color.white],
  },
  editor = {
    fg = Color[Color.black],
    bg = Color[Color.white],
    highlight = Color[Color.white + Color.bright],
    highlight_loaded = Color[Color.yellow + Color.bright],
    highlight_special = special,
  },
  input = {
    console = {
      bg = Color[Color.white],
      fg = Color[Color.black + Color.bright],
    },
    user = {
      bg = Color[Color.white],
      fg = Color[Color.black + Color.bright],
    },
    inspect = {
      bg = Color[Color.white],
      fg = Color[Color.blue + Color.bright],
    },
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
    console = {
      fg = Color[Color.white + Color.bright],
      bg = Color[Color.black],
      indicator = indicator,
      special = special,
    },
    user = {
      bg = Color[Color.blue],
      fg = Color[Color.white],
      indicator = indicator,
      special = special,
    },
    inspect = {
      bg = Color[Color.red],
      fg = Color[Color.black],
      indicator = indicator,
      special = special,
    },
    editor = {
      fg = Color[Color.white + Color.bright],
      fg2 = Color[Color.yellow + Color.bright],
      bg = Color[Color.blue],
      indicator = indicator,
      special = special,
    },
  },
}
