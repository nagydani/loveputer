local _ = require("view/color")

ConsoleView = {}

function ConsoleView:new(m, cfg)
  local view = {
    model = m
  }
  local conf = {
    fontSize = 18,
    colors = {
      bg = Color[Color.white],
      border = Color[Color.black + Color.bright],
      fg = Color[Color.blue + Color.bright],
    }
  }
  for k, v in pairs(cfg) do
    conf[k] = v
  end

  setmetatable(view, self)
  self.__index = self

  local fontDir = "assets/fonts/"
  view.font_ps = love.graphics.newFont(
    fontDir .. "PressStart2P-Regular.ttf", cfg.fontSize)
  view.font_8bit = love.graphics.newFont(
    fontDir .. "8bitOperatorPlus8-Bold.ttf", cfg.fontSize)
  view.cfg = conf

  return view
end

function ConsoleView:draw(x, y, w, h)
  local G = love.graphics
  local fac = 1
  if _G.hiDPI then fac = 2 end
  G.scale(fac, fac)

  G.setFont(self.font_ps)
  local z = G.getFont():getHeight()

  w = w or G.getWidth()
  h = h or G.getHeight()
  w = w / fac
  h = h / fac
  x = x or 0
  y = y or 0
  local border = 4 * (2 / fac)
  local canvasDrawableHeight =
      h - border -- top border
      - z        -- separator
      - z        -- input line
      - border   -- bottom border
  local linesN = math.floor(canvasDrawableHeight / z)

  local background = {
    draw = function()
      G.setColor(self.cfg.colors.border)
      G.rectangle("fill", 0, 0, w, h)
      G.setColor(self.cfg.colors.bg)
      G.rectangle("fill", border, border, w - 2 * border, h - 2 * border)
      -- separator
      G.setColor(self.cfg.colors.border)
      G.rectangle("fill", 0, h - border - 2 * z - border, w, z)
    end,
  }

  local canvas = {
    draw = function()
      local function writeLine(l, text)
        if l < 0 or l > canvasDrawableHeight then return end
        local cx = border + 1
        local lineOffset = (l - 1) * z
        local cy = border + 1 + lineOffset
        G.setColor(self.cfg.colors.fg)
        G.print(text, cx, cy)
      end

      for i = 1, (linesN) do
        writeLine(i, '#' .. i .. ' ' .. self.model.n)
      end
    end
  }

  background.draw()
  canvas.draw()
end
