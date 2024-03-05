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
--- @param pos table
--- @param cfg ViewConfig
local write_line = function(l, str, pos, cfg)
  local dy = pos.y - (-l + 1) * cfg.fh
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
    return love.debug[k]
  end
  return true
end

ViewUtils = {
  get_drawable_height = get_drawable_height,
  write_line = write_line,
  conditional_draw = conditional_draw,
}
