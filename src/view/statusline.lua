local G = love.graphics

Statusline = {}

function Statusline:new(cfg)
  local s = {
    cfg = cfg,
  }
  setmetatable(s, self)
  self.__index = self

  return s
end

---@param status Status
---@param nLines integer
---@param time number?
---@param oneshot boolean?
function Statusline:draw(status, nLines, time, oneshot)
  local cf = self.cfg.view
  local b = cf.border
  local h = cf.h
  local w = cf.w
  local fh = cf.fh
  local colors = cf.colors
  local fg, bg = (function()
    if oneshot then
      return colors.statusline.user.fg, colors.statusline.user.bg
    end
    return colors.statusline.fg, colors.statusline.bg
  end)()


  G.push('all')
  G.setColor(bg)
  G.setFont(cf.font)
  local sy = h - b - (1 + nLines) * fh
  local start_box = { x = 0, y = sy }
  local start_text = {
    x = start_box.x + fh,
    y = start_box.y,
  }
  local endTextX = start_box.x + w - fh
  local midX = (start_box.x + w) / 2
  G.rectangle("fill", start_box.x, start_box.y, w, fh)

  if not status then return end
  G.setColor(fg)
  if status.input_type then
    G.print(status.input_type, start_text.x, start_text.y)
  end
  if love.DEBUG then
    G.setColor(colors.debug)
    if love.state.testing then
      G.print('testing', midX - (8 * cf.fw + cf.border), start_text.y)
    end
    if time then
      G.print(tostring(time), midX, start_text.y)
    end
    G.setColor(fg)
  end
  if status.cursor then
    local c = status.cursor
    local pos_l = 'L' .. c.l
    local pos_c = ':' .. c.c
    local lw = G.getFont():getWidth(pos_l)
    local cw = G.getFont():getWidth(pos_c)
    local sx = endTextX - (lw + cw)
    if c.l == status.n_lines then
      G.setColor(colors.statusline.indicator)
    end
    G.print(pos_l, sx, start_text.y)
    G.setColor(fg)
    G.print(pos_c, sx + lw, start_text.y)
  end
  G.pop()
end
