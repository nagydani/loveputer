require("util/dequeue")
require("util/string")

local G = love.graphics

CanvasModel = {}


function CanvasModel:new(cfg)
  local w = G.getWidth() - 2 * cfg.border
  local h = cfg.get_drawable_height() + cfg.fh
  local linesN = math.floor(cfg.get_drawable_height() / cfg.fh)
  local colsN = math.floor(w / cfg.fw)
  local cm = {
    canvas = love.graphics.newCanvas(w, h),
    terminal = {
      rows = linesN,
      columns = colsN,
      colors = {
        bg = Color[Color.blue],
        fg = Color[Color.white + Color.bright],
      },
      cursor = { l = 1, c = 1 }
    },
    cfg = cfg,
  }
  setmetatable(cm, self)
  self.__index = self


  cm.background = function()
    G.setColor(cm.terminal.colors.bg)
    G.rectangle("fill", 0, 0, cfg.w, cfg.h)
  end
  G.push('all')
  cm.canvas:renderTo(cm.background)
  G.pop()

  return cm
end

function CanvasModel:_manipulate(commands)
  self.canvas:renderTo(function()
    for _, c in ipairs(commands) do
      local f = load(c)
      if f then f() end
    end
  end)
end

function CanvasModel:write_line(text)
  if string.is_non_empty_string(text) then
    local function f()
      G.setColor(self.terminal.colors.fg)
      local cur = self.terminal.cursor
      local cx = cur.c
      local cl = cur.l
      local lineOffset = cur.l
      local cy = (lineOffset - 1) * self.cfg.fh
      G.print(text, cx, cy)
      self.terminal.cursor.l = cl + 1
    end

    self.canvas:renderTo(f)
  end
end

function CanvasModel:push(newResult)
  for _, v in ipairs(newResult) do
    self:write_line(v)
  end
end

function CanvasModel:clear()
  self.canvas:renderTo(self.background)
end
