local G = love.graphics

require("view/statusline")

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
  local fh = self.cfg.fh
  local b = cf.border
  local h = cf.height
  local y = h - b - fh
  local function drawCursor()
    local _, cc = self.controller.model.input:get_cursor_pos()
    -- we use a monospace font, so the width should be the same for any input
    local fw = self.cfg.font_main:getWidth('a')
    local offset = fw * (cc)
    local w_off = fw
    G.print('|', offset - w_off, y)
  end
  self.statusline:draw(self.controller:get_status())
  G.setColor(cf.colors.fg)
  G.print(input, b, y)
  drawCursor()
end
