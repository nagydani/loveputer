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

ViewUtils = {
  get_drawable_height = get_drawable_height,
}
