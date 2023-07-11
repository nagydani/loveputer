local _ = require("view/color")

local G = love.graphics

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
  view.font_main = love.graphics.newFont(
    fontDir .. "ubuntu_mono_bold_nerd.ttf", cfg.fontSize)
  view.font_title = love.graphics.newFont(
    fontDir .. "PressStart2P-Regular.ttf", cfg.fontSize)
  view.cfg = conf

  local FAC = 1
  if _G.hiDPI then FAC = 2 end
  local BORDER = 4 * (2 / FAC)
  view.fac = FAC
  view.border = BORDER
  G.scale(FAC, FAC)
  G.setFont(view.font_main)
  local FH = view.font_main:getHeight()
  view.fh = FH
  view.getDrawableHeight = function(h)
    return
        h - BORDER -- top border
        - FH       -- separator
        - FH       -- input line
        - BORDER   -- bottom border
  end

  return view
end

function ConsoleView:resize(wi, hi)
  local w = wi / self.fac
  local h = hi / self.fac

  self.canvasDrawableHeight = self.getDrawableHeight(h)

  local inputBox = {
    x = self.border,
    y = self.border + self.canvasDrawableHeight + 2 * self.border,
    w = w - 2 * self.border,
    h = self.fh,
  }

  love.keyboard.setTextInput(true,
    inputBox.x, inputBox.y, inputBox.w, inputBox.h)
end

function ConsoleView:draw(x, y, w, h)
  local b = self.border

  G.scale(self.fac, self.fac)

  w = (w or G.getWidth()) / self.fac
  h = (h or G.getHeight()) / self.fac
  x = x or 0
  y = y or 0

  if not self.canvasDrawableHeight then
    self.canvasDrawableHeight = self.getDrawableHeight(h)
  end

  local linesN = math.floor(self.canvasDrawableHeight / self.fh)

  local background = {
    draw = function()
      G.setColor(self.cfg.colors.border)
      G.rectangle("fill", 0, 0, w, h)
      G.setColor(self.cfg.colors.bg)
      G.rectangle("fill", b, b, w - 2 * b, h - 2 * b)
      -- separator
      G.setColor(self.cfg.colors.border)
      G.rectangle("fill", 0, h - b - 2 * self.fh - b, w, self.fh)
    end,
  }

  local canvas = {
    draw = function()
      local function writeLine(l, text)
        if l < 0 or l > linesN then return end
        local cx = b + 1
        local lineOffset = (l - 1) * self.fh
        local cy = b + 1 + lineOffset
        G.setColor(self.cfg.colors.fg)
        G.print(text, cx, cy)
      end

      local function testCanvas()
        for i = 1, linesN do
          writeLine(i, '#' .. i .. ' ' .. self.model.n)
        end
      end

      local output = self.model.result
      for i = 1, #output do
        writeLine(i, output[i])
      end
    end
  }

  local input = {
    draw = function()
      G.setColor(self.cfg.colors.fg)
      G.print(self.model.entered, b, h - b - self.fh)
    end
  }

  background.draw()
  canvas.draw()
  input.draw()
end
