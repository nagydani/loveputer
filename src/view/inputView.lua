local G = love.graphics

local _ = require("view/statusline")

InputView = {}

function InputView:new(cfg, ctrl)
  local iv = {
    cfg = cfg,
    controller = ctrl,
    statusline = Statusline:new(cfg),
  }
  setmetatable(iv, self)
  self.__index = self

  return iv
end

function InputView:draw(input)
  local cf = self.cfg
  local b = cf.border
  local h = cf.height
  local y = h - b - self.cfg.fh
  local function drawCursor()
    local offset = self.cfg.font_main:getWidth(input)
    G.print('_', b + offset, y)
  end
  self.statusline:draw(self.controller:getStatus())
  G.setColor(cf.colors.fg)
  G.print(input, b, y)
  drawCursor()
end
