local G = love.graphics

--- @class Statusline
--- @field cfg ViewConfig
Statusline = {}

--- @param cfg ViewConfig
--- @return Statusline
function Statusline:new(cfg)
  local s = {
    cfg = cfg,
  }
  setmetatable(s, self)
  self.__index = self

  return s
end

--- @param status Status
--- @param nLines integer
--- @param time number?
function Statusline:draw(status, nLines, time)
  local cf = self.cfg
  local colors = (function()
    if love.state.app_state == 'inspect' then
      return cf.colors.statusline.inspect
    elseif love.state.app_state == 'running' then
      return cf.colors.statusline.user
    elseif love.state.app_state == 'editor' then
      return cf.colors.statusline.editor
    else
      return cf.colors.statusline.console
    end
  end)()
  local b = cf.border
  local h = cf.h
  local w = cf.w
  local fh = cf.fh
  local font = cf.font

  local sy = h - b - (1 + nLines) * fh
  local start_box = { x = 0, y = sy }
  local endTextX = start_box.x + w - fh
  local midX = (start_box.x + w) / 2

  local function drawBackground()
    G.setColor(colors.bg)
    G.setFont(font)
    local corr = 2 -- correct for fractional slit left under the terminal
    G.rectangle("fill", start_box.x, start_box.y - corr, w, fh + corr)
  end

  local function drawStatus()
    local custom = status.custom
    local start_text = {
      x = start_box.x + fh,
      y = start_box.y - 2,
    }

    G.setColor(colors.fg)
    if status.input_type then
      G.print(status.input_type, start_text.x, start_text.y)
    end
    if love.DEBUG then
      G.setColor(cf.colors.debug)
      if love.state.testing then
        G.print('testing', midX - (8 * cf.fw + cf.border), start_text.y)
      end
      G.print(love.state.app_state, midX - (13 * cf.fw), start_text.y)
      if time then
        G.print(tostring(time), midX, start_text.y)
      end
      G.setColor(colors.fg)
    end
    local c = status.cursor
    if type(c) == 'table' then
      local pos_l = 'L' .. c.l
      local pos_c = ':' .. c.c
      local lw = G.getFont():getWidth(pos_l)
      local cw = G.getFont():getWidth(pos_c)
      local sx = endTextX - (lw + cw)
      if custom then
        pos_l = 'L' .. custom.line
      else
        if c.l == status.n_lines then
          G.setColor(colors.indicator)
        end
      end
      G.print(pos_l, sx, start_text.y)
      G.setColor(colors.fg)
      G.print(pos_c, sx + lw, start_text.y)
    end
  end

  G.push('all')
  drawBackground()
  drawStatus()
  G.pop()
end
