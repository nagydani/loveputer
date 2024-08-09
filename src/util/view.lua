--- @param cfg ViewConfig
--- @return number
local get_drawable_height = function(cfg)
  local ch = cfg.fh * cfg.lh
  local d = cfg.h - cfg.border -- top border
      - cfg.border             -- statusline border
      - cfg.fh                 -- statusline
      - cfg.border             -- statusline bottom border
      - cfg.fh                 -- input line
      - cfg.border             -- bottom border
  local n_lines = math.floor(d / ch)
  local res = n_lines * ch
  return res
end

--- Write a line of text to output
--- @param l number
--- @param str string
--- @param y number
--- @param breaks integer
--- @param cfg ViewConfig
local write_line = function(l, str, y, breaks, cfg)
  local dy = y - (-l + 1 + breaks) * cfg.fh
  G.setFont(cfg.font)
  G.print(str, cfg.border, dy)
end

--- Hide elements for debugging
--- Return true if DEBUG is not enabled or is
--- enabled and the appropriate flag is set
--- @param k string
--- @return boolean
local conditional_draw = function(k)
  if love.DEBUG then
    return love.debug[k] == true
  end
  return true
end

--[[
AlphaMode = AlphaM | PreM
BlendMode = Alpha AlphaMode
            Add AlphaMode
            Subtract AlphaMode
            Replace AlphaMode
            Multiply PreM
            Darken PreM
            Lighten PreM
            Screen AlphaMode
]]
local blendModes = {
  { -- 1
    name = 'Alpha AlphaM',
    blend = function() G.setBlendMode('alpha', "alphamultiply") end
  },
  { -- 2
    name = 'Alpha PreM',
    blend = function() G.setBlendMode('alpha', "premultiplied") end
  },
  -- add
  {
    name = 'Add AlphaM',
    blend = function() G.setBlendMode('add', "alphamultiply") end
  },
  {
    name = 'Add PreM',
    blend = function() G.setBlendMode('add', "premultiplied") end
  },
  -- subtract
  {
    name = 'Subtract AlphaM',
    blend = function() G.setBlendMode('subtract', "alphamultiply") end
  },
  {
    name = 'Subtract PreM',
    blend = function() G.setBlendMode('subtract', "premultiplied") end
  },
  -- replace
  {
    name = 'Replace AlphaM',
    blend = function() G.setBlendMode('replace', "alphamultiply") end
  },
  {
    name = 'Replace PreM',
    blend = function() G.setBlendMode('replace', "premultiplied") end
  },

  -- pre only
  {
    name = 'Multiply PreM',
    blend = function() G.setBlendMode('multiply', "premultiplied") end
  },
  {
    name = 'Darken PreM',
    blend = function() G.setBlendMode('darken', "premultiplied") end
  },
  {
    name = 'Lighten PreM',
    blend = function() G.setBlendMode('lighten', "premultiplied") end
  },
  -- screen
  {
    name = 'Screen AlphaM',
    blend = function() G.setBlendMode('screen', "alphamultiply") end
  },
  {
    name = 'Screen PreM',
    blend = function() G.setBlendMode('screen', "premultiplied") end
  },
}

ViewUtils = {
  get_drawable_height = get_drawable_height,
  write_line = write_line,
  conditional_draw = conditional_draw,

  blendModes = blendModes,
}
