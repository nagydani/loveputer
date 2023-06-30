local _ = require("view/color")

ConsoleView = {}

function ConsoleView:new(m, cfg)
  local view = {
    model = m
  }
  local conf = {
    fontSize = 18,
    colors = {
      bg = 0,
      fg = 1,
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
  if _G.hiDPI then G.scale(2, 2) end


  G.setFont(self.font_ps)
  local z = G.getFont():getHeight()

  w = w or G.getWidth()
  h = h or G.getHeight()
  x = x or 0
  y = y or 0

  G.setColor(Color['black'])
  G.rectangle("fill", x, y, w, h)
  G.setColor(Color['white'])
  G.print(self.model.n)
  G.setFont(self.font_8bit)
  local offset = z * 1.2
  G.print(self.model.n, 0, offset)
end
