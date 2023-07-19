local G = love.graphics

CanvasView = {}

function CanvasView:new(cfg)
  local cv = {
    cfg = cfg,
  }
  setmetatable(cv, self)
  self.__index = self

  local BORDER = cfg.border
  local FH = cfg.fh

  cv.get_drawable_height = function()
    local height = G.getHeight()
    return
        height - BORDER -- top border
        - BORDER        -- statusline border
        - FH            -- statusline
        - BORDER        -- statusline bottom border
        - FH            -- input line
        - BORDER        -- bottom border
  end
  local w = G.getWidth() - 2 * BORDER
  local h = cv.get_drawable_height() + FH

  cv.canvas = love.graphics.newCanvas(w, h)
  cv.terminal = {
    colors = {
      bg = Color[Color.blue],
      fg = Color[Color.white + Color.bright],
    },
    cursor = { l = 1, c = 1 }
  }
  cv.w = w
  cv.h = h
  cv.canvas_drawable_height = cv.get_drawable_height()

  return cv
end

function CanvasView:draw(output)
  local b = self.cfg.border
  local linesN = math.floor(self.canvas_drawable_height / self.cfg.fh)

  local function write_line(l, text)
    if l < 0 or l > linesN then return end
    local cx = b + 1
    local lineOffset = (l - 1) * self.cfg.fh
    local cy = b + 1 + lineOffset
    G.print(text or '', cx, cy)
  end

  -- draw internal canvas
  local background = {
    draw = function()
      G.setCanvas(self.canvas)
      G.clear(0, 0, 0, 0)
      G.setColor(self.terminal.colors.bg)
      G.rectangle("fill", 0, 0, self.w, self.h)
    end,
  }
  background.draw()
  G.setColor(self.terminal.colors.fg)
  local offset = 0
  if #output > linesN then
    offset = #output - linesN
  end
  for i = 1, #output do
    write_line(i, output[i + offset])
  end

  -- return to main canvas
  G.setCanvas()
  local img = self.canvas
  local tf = love.math.newTransform()
  tf:translate(b, b)
  G.draw(img, tf)
end
