local class = require("util.class")

--- @class Statusline
--- @field cfg ViewConfig
Statusline = class.create(function(cfg)
  return { cfg = cfg }
end)


--- @param status Status
--- @param nLines integer
--- @param time number?
function Statusline:draw(status, nLines, time)
  local G = love.graphics
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

  --- @param m More?
  --- @return string
  local function morelabel(m)
    local l = ''
    if not m then return '' end

    if m.up and not m.down then
      return '↑↑'
    elseif not m.up and m.down then
      return '↓↓ '
    elseif m.up and m.down then
      return '↕↕ '
    else
      return ''
    end
  end

  local function drawStatus()
    local custom = status.custom
    local start_text = {
      x = start_box.x + fh,
      y = start_box.y - 2,
    }

    G.setColor(colors.fg)
    local label = status.label
    if label then
      G.print(label, start_text.x, start_text.y)
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
      if custom then
        local t_ic = ' ' .. c.l .. ':' .. c.c
        local lim = custom.buflen
        local sel, t_bbp, t_blp
        -- local more_i = ''
        if custom.content_type == 'plain' then
          sel = custom.selection
          t_blp = 'L' .. sel
        end
        if custom.content_type == 'lua' then
          sel = custom.selection
          t_bbp = 'B' .. sel .. ' '
          t_blp = custom.range:ln_label()
        end
        local more_b = morelabel(custom.buffer_more) .. ' '
        local more_i = morelabel(status.input_more) .. ' '

        G.setColor(colors.fg)
        local w_il  = G.getFont():getWidth(" 999:9999")
        local w_br  = G.getFont():getWidth("B999 L999-999(99)")
        local w_mb  = G.getFont():getWidth(" ↕↕ ")
        local w_mi  = G.getFont():getWidth("  ↕↕ ")
        local s_mb  = endTextX - w_br - w_il - w_mi - w_mb
        local cw_p  = G.getFont():getWidth(t_blp)
        local cw_il = G.getFont():getWidth(t_ic)
        local sxl   = endTextX - (cw_p + w_il + w_mi)
        local s_mi  = endTextX - w_il


        G.setFont(self.cfg.font)
        G.setColor(colors.fg)
        if colors.fg2 then G.setColor(colors.fg2) end
        --- cursor pos
        G.print(t_ic, endTextX - cw_il, start_text.y)
        --- input more
        G.setFont(self.cfg.iconfont)
        G.print(more_i, s_mi, start_text.y - 3)

        G.setColor(colors.fg)
        --- block line range / line
        G.setFont(self.cfg.font)
        G.print(t_blp, sxl, start_text.y)
        --- block number
        if custom.content_type == 'lua' then
          local bpw = G.getFont():getWidth(t_bbp)
          local sxb = sxl - bpw
          if sel == lim then
            G.setColor(colors.indicator)
          end
          G.print(t_bbp, sxb, start_text.y)
        end

        --- buffer more
        G.setColor(colors.fg)
        G.setFont(self.cfg.iconfont)
        G.print(more_b, s_mb, start_text.y - 3)
      else
        --- normal statusline
        local pos_c = ':' .. c.c
        local ln, l_lim
        if custom then
          ln = custom.line
          l_lim = custom.buflen
        else
          ln = c.l
          l_lim = status.n_lines
        end
        if ln == l_lim then
          G.setColor(colors.indicator)
        end
        local pos_l = 'L' .. ln

        local lw = G.getFont():getWidth(pos_l)
        local cw = G.getFont():getWidth(pos_c)
        local sx = endTextX - (lw + cw)
        G.print(pos_l, sx, start_text.y)
        G.setColor(colors.fg)
        G.print(pos_c, sx + lw, start_text.y)
      end
    end
  end

  G.push('all')
  drawBackground()
  drawStatus()
  G.pop()
end
