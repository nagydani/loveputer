local G = love.graphics

InputView = {}

function InputView:new(cfg)
  local iv = {
    cfg = cfg,
  }
  setmetatable(iv, self)
  self.__index = self

  return iv
end

function InputView:draw(input)
  local b = self.cfg.border
  local h = self.cfg.height
  G.setColor(self.cfg.colors.fg)
  G.print(input, b, h - b - self.cfg.fh)
end
