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
  local time = self.controller:get_timestamp()
  local cf = self.cfg
  local fh = self.cfg.fh
  local w = self.cfg.width
  local status = self.controller:get_status()
  local b = cf.border
  local fullHeight = cf.height
  local inLines = #input
  local inHeight = inLines * fh
  local y = fullHeight - b - inHeight
  local function drawCursor()
    local cl, cc = self.controller.model.input:get_cursor_pos()
    -- we use a monospace font, so the width should be the same for any input
    local fw = self.cfg.font_main:getWidth('a')
    local offset = fw * cc
    local w_off = fw
    local ch = y - (-cl + 1) * fh
    G.print('|', offset - w_off, ch)
  end

  local h = self.cfg.height
  local inputBackground = {
    draw = function()
      G.setColor(self.cfg.colors.bg)
      G.rectangle("fill",
        b,
        h - b - inLines * fh,
        w - 2 * b, inLines * fh)
    end,
  }

  inputBackground.draw()
  self.statusline:draw(
    status,
    inLines,
    time
  )
  G.setColor(cf.colors.fg)
  for i, l in ipairs(input) do
    local dy = y - (-i + 1) * fh
    G.print(l, b, dy)
  end
  local blink = math.floor(math.floor(time * 2) % 2) == 0
  if blink then
    drawCursor()
  end
end
