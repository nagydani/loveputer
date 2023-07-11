local G = love.graphics

local _ = require("view/statusline")

InputView = {}

function InputView:new(cfg)
  local iv = {
    cfg = cfg,
    statusline = Statusline:new(cfg)
  }
  setmetatable(iv, self)
  self.__index = self

  return iv
end

function InputView:draw(input)
  local cf = self.cfg
  local b = cf.border
  local h = cf.height
  self.statusline:draw(self.status)
  G.setColor(cf.colors.fg)
  G.print(input, b, h - b - self.cfg.fh)
end
