require("util/dequeue")
require("util/string")

local G = love.graphics

CanvasModel = {}


function CanvasModel:new(cfg)
  local w = G.getWidth() - 2 * cfg.border
  local h = cfg.get_drawable_height() + cfg.fh
  local cm = {
    canvas = love.graphics.newCanvas(w, h),
    result = Dequeue:new(),
    terminal = {
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


  local background = {
    draw = function()
      G.clear(0, 0, 0, 0)
      G.setBlendMode('alpha')
      G.setColor(cm.terminal.colors.bg)
      G.setColor(Color[Color.blue])
      G.rectangle("fill", 0, 0, cfg.w, cfg.h)
    end,
  }
  cm.canvas:renderTo(background.draw)

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

function CanvasModel:push(newResult)
  if StringUtils:is_non_empty_string_array(newResult) then
    self.result:push(newResult)
  end
end
